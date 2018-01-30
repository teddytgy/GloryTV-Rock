#region License

/* 
 * All content copyright Terracotta, Inc., unless otherwise indicated. All rights reserved. 
 * 
 * Licensed under the Apache License, Version 2.0 (the "License"); you may not 
 * use this file except in compliance with the License. You may obtain a copy 
 * of the License at 
 * 
 *   http://www.apache.org/licenses/LICENSE-2.0 
 *   
 * Unless required by applicable law or agreed to in writing, software 
 * distributed under the License is distributed on an "AS IS" BASIS, WITHOUT 
 * WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the 
 * License for the specific language governing permissions and limitations 
 * under the License.
 * 
 */

#endregion

using System;
using System.Threading;

using Quartz.Collection;
using Quartz.Impl.AdoJobStore.Common;
using Quartz.Util;

namespace Quartz.Impl.AdoJobStore
{
    /// <summary>
    /// Base class for database based lock handlers for providing thread/resource locking 
    /// in order to protect resources from being altered by multiple threads at the 
    /// same time.
    /// </summary>
    /// <author>Marko Lahma (.NET)</author>
    public abstract class DBSemaphore : StdAdoConstants, ISemaphore, ITablePrefixAware
    {
        private const string ThreadContextKeyLockOwners = "qrtz_dbs_lck_owners";
        private string sql;
        private String insertSql;

        private string tablePrefix;

        private string schedName; 

        private string expandedSQL;
        private string expandedInsertSQL;

        private readonly AdoUtil adoUtil;

        /// <summary>
        /// Initializes a new instance of the <see cref="DBSemaphore"/> class.
        /// </summary>
        /// <param name="tablePrefix">The table prefix.</param>
        /// <param name="schedName">the scheduler name</param>
        /// <param name="defaultInsertSQL">The SQL.</param>
        /// <param name="defaultSQL">The default SQL.</param>
        /// <param name="dbProvider">The db provider.</param>
        public DBSemaphore(string tablePrefix, string schedName, string defaultSQL, string defaultInsertSQL, IDbProvider dbProvider)
        {
            this.schedName = schedName;
            this.tablePrefix = tablePrefix;
            SQL = defaultSQL;
            InsertSQL = defaultInsertSQL;
            adoUtil = new AdoUtil(dbProvider);
        }

        /// <summary>
        /// Gets or sets the lock owners.
        /// </summary>
        /// <value>The lock owners.</value>
        private static HashSet<string> LockOwners
        {
            get { return LogicalThreadContext.GetData<HashSet<string>>(ThreadContextKeyLockOwners); }
            set { LogicalThreadContext.SetData(ThreadContextKeyLockOwners, value); }
        }

        private static HashSet<string> ThreadLocks
        {
            get
            {
                if (LockOwners == null)
                {
                    LockOwners = new HashSet<string>();
                }
                return LockOwners;
            }
        }

        /// <summary>
        /// Execute the SQL that will lock the proper database row.
        /// </summary>
        /// <param name="conn"></param>
        /// <param name="lockName"></param>
        /// <param name="expandedSQL"></param>
        /// <param name="expandedInsertSQL"></param>
        protected abstract void ExecuteSQL(ConnectionAndTransactionHolder conn, string lockName, string expandedSQL, string expandedInsertSQL);


        /// <summary>
        /// Grants a lock on the identified resource to the calling thread (blocking
        /// until it is available).
        /// </summary>
        /// <param name="metadata"></param>
        /// <param name="conn"></param>
        /// <param name="lockName"></param>
        /// <returns>true if the lock was obtained.</returns>
        public bool ObtainLock(DbMetadata metadata, ConnectionAndTransactionHolder conn, string lockName)
        {
            lockName = string.Intern(lockName);

            if (!IsLockOwner(conn, lockName))
            {
                ExecuteSQL(conn, lockName, expandedSQL, expandedInsertSQL);

                ThreadLocks.Add(lockName);
                //getThreadLocksObtainer().put(lockName, new
                // Exception("Obtainer..."));
            }

            return true;
        }


        /// <summary>
        /// Release the lock on the identified resource if it is held by the calling
        /// thread.
        /// </summary>
        /// <param name="conn"></param>
        /// <param name="lockName"></param>
        public void ReleaseLock(ConnectionAndTransactionHolder conn, string lockName)
        {
            lockName = string.Intern(lockName);

            if (IsLockOwner(conn, lockName))
            {
                ThreadLocks.Remove(lockName);
                //getThreadLocksObtainer().remove(lockName);
            }
        }

        /// <summary>
        /// Determine whether the calling thread owns a lock on the identified
        /// resource.
        /// </summary>
        /// <param name="conn"></param>
        /// <param name="lockName"></param>
        /// <returns></returns>
        public bool IsLockOwner(ConnectionAndTransactionHolder conn, string lockName)
        {
            lockName = string.Intern(lockName);

            return ThreadLocks.Contains(lockName);
        }

        /// <summary>
        /// This Semaphore implementation does use the database.
        /// </summary>
        public bool RequiresConnection
        {
            get { return true; }
        }

        protected string SQL
        {
            get { return sql; }
            set
            {
                if (!value.IsNullOrWhiteSpace())
                {
                    sql = value.Trim();
                }
                SetExpandedSql();
            }
        }


        protected string InsertSQL
        {
            set
            {
                if (!value.IsNullOrWhiteSpace())
                {
                    insertSql = value.Trim();
                }

                SetExpandedSql();
            }
        }



        private void SetExpandedSql()
        {
            if (TablePrefix != null && SchedName != null && sql != null && insertSql != null)
            {
                expandedSQL = AdoJobStoreUtil.ReplaceTablePrefix(sql, TablePrefix, SchedulerNameLiteral);
                expandedInsertSQL = AdoJobStoreUtil.ReplaceTablePrefix(insertSql, TablePrefix, SchedulerNameLiteral);
            }
        }

        private String schedNameLiteral;

        protected string SchedulerNameLiteral
        {
            get
            {
                if (schedNameLiteral == null)
                {
                    schedNameLiteral = "'" + schedName + "'";
                }
                return schedNameLiteral;
            }
        }

        public string SchedName
        {
            get { return schedName; }
            set 
            {
                schedName = value;
                SetExpandedSql();
            }
        }

        /// <summary>
        /// Gets or sets the table prefix.
        /// </summary>
        /// <value>The table prefix.</value>
        public string TablePrefix
        {
            get { return tablePrefix; }
            set
            {
                tablePrefix = value;
                SetExpandedSql();
            }
        }

        protected AdoUtil AdoUtil
        {
            get { return adoUtil; }
        }
    }
}