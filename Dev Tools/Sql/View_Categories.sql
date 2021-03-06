SELECT et.NAME AS [EntityType.Name]
    ,CASE 
        WHEN c.EntityTypeQualifierColumn = 'EntityTypeId'
            THEN etq.NAME
        ELSE NULL
        END [Qualifier]
    ,c.NAME [Category.Name]
    ,c.IconCssClass
    ,c.[Guid] [Category.Guid]
FROM Category c
LEFT JOIN EntityType et ON et.Id = c.EntityTypeId
LEFT JOIN EntityType etq ON c.EntityTypeQualifierValue = convert(VARCHAR(200), etq.Id)
ORDER BY et.NAME
    ,etq.NAME
    ,c.NAME
