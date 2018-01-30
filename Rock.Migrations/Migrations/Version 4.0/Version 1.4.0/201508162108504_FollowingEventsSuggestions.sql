-- Update the Homepage and Error layouts on RockRMS site to be system
DECLARE @SiteId int = ( SELECT TOP 1 [Id] FROM [Site] WHERE [Guid] = 'C2D29296-6A87-47A9-A753-EE4E9159C4C4' )
UPDATE [Layout] SET 
	 [IsSystem] = 1
	,[Guid] = 'CABD576F-C700-4690-835A-1BFBDD7DCBE6'
WHERE [SiteId] = @SiteId
AND [FileName] = 'HomePage'

UPDATE [Layout] SET 
	 [IsSystem] = 1
	,[Guid] = '7E816087-6A8C-498E-BFE7-D0B684A9DD45'
WHERE [SiteId] = @SiteId
AND [FileName] = 'Error'

-- Update the Blank layout on external website to be system
SET @SiteId = ( SELECT TOP 1 [Id] FROM [Site] WHERE [Guid] = 'F3F82256-2D66-432B-9D67-3552CD2F4C2B' )
UPDATE [Layout] SET 
	 [IsSystem] = 1
	,[Guid] = '7E4EC84E-A7BD-426B-AC77-230F28481FF0'
WHERE [SiteId] = @SiteId
AND [FileName] = 'Blank'

-- Update the Blank layout on checkin website to be system
SET @SiteId = ( SELECT TOP 1 [Id] FROM [Site] WHERE [Guid] = 'A5FA7C3C-A238-4E0B-95DE-B540144321EC' )
UPDATE [Layout] SET 
	 [IsSystem] = 1
	,[Guid] = 'BD09B885-8255-4DFD-88FE-E4CDAA6981D1'
WHERE [SiteId] = @SiteId
AND [FileName] = 'Blank'

-- Update the order of other blocks on the dashboard sidebar
UPDATE B SET [Order] = B.[Order] + 1
FROM [Page] P
INNER JOIN [Block] B
	ON B.[PageId] = P.[Id]
	AND B.[Zone] = 'Sidebar1'
	AND B.[Name] <> 'Person Suggestion Notice'
WHERE P.[Guid] = 'AE1818D8-581C-4599-97B9-509EA450376A'

-- Add Birthday following event types
DECLARE @PersonAliasEntityTypeId int = ( SELECT TOP 1 [Id] FROM [EntityType] WHERE [Name] = 'Rock.Model.PersonAlias' )
DECLARE @EntityTypeId int = ( SELECT TOP 1 [Id] FROM [EntityType] WHERE [Guid] = '532A7405-A3FB-4147-BE67-3B75A230AADE' )
DECLARE @AttributeId int = ( SELECT TOP 1 [Id] FROM [Attribute] WHERE [Guid] = 'F5B35909-5A4A-4203-84A8-7F493E56548B' )
IF @EntityTypeId IS NOT NULL
BEGIN

	INSERT INTO [FollowingEventType] ( [Name], [Description], [EntityTypeId], [FollowedEntityTypeId], [IsActive], [SendOnWeekends], [IsNoticeRequired], [EntityNotificationFormatLava], [Guid] )
	VALUES 
	    ( 'Upcoming Birthday', 'Person with an upcoming birthday', @EntityTypeId, @PersonAliasEntityTypeId, 1, 0, 0, 
'<tr>
    <td>
        {% if Entity.Person.PhotoId %} 
            <img src=''{{ ''Global'' | Attribute:''PublicApplicationRoot'' }}GetImage.ashx?id={{ Entity.Person.PhotoId }}&maxwidth=120&maxheight=120''/>
        {% endif %}
    </td>
    <td>
        <strong><a href="{{ ''Global'' | Attribute:''PublicApplicationRoot'' }}Person/{{ Entity.PersonId }}">{{ Entity.Person.FullName }}</a> has a birthday on 
        {{ Entity.Person.NextBirthDay | Date:''dddd, MMMM dd'' }} ({{ Entity.Person.NextBirthDay | HumanizeDateTime }})</strong><br />

        {% if Entity.Person.Email != empty %}
            Email: <a href="mailto:{{ Entity.Person.Email }}">{{ Entity.Person.Email }}</a><br />
        {% endif %}
        
        {% assign mobilePhone = Entity.Person.PhoneNumbers | Where:''NumberTypeValueId'', 136 | Select:''NumberFormatted'' %}
        {% if mobilePhone != empty %}
            Cell: {{ mobilePhone }}<br />
        {% endif %}
        
        {% assign homePhone = Entity.Person.PhoneNumbers | Where:''NumberTypeValueId'', 13 | Select:''NumberFormatted'' %}
        {% if homePhone != empty %}
            Home: {{ homePhone }}<br />
        {% endif %}
        
    </td>
</tr>', 'E1C2F8BD-E875-4C7B-91A1-EDB98AB01BDC' ),
	    ( 'Birthday', 'Person with a birthday today (or this weekend)', @EntityTypeId, @PersonAliasEntityTypeId, 1, 0, 1, 
'<tr>
    <td>
        {% if Entity.Person.PhotoId %} 
            <img src=''{{ ''Global'' | Attribute:''PublicApplicationRoot'' }}GetImage.ashx?id={{ Entity.Person.PhotoId }}&maxwidth=120&maxheight=120''/>
        {% endif %}
    </td>
    <td>
        <strong><a href="{{ ''Global'' | Attribute:''PublicApplicationRoot'' }}Person/{{ Entity.PersonId }}">{{ Entity.Person.FullName }}</a> has a birthday on 
        {{ Entity.Person.NextBirthDay | Date:''dddd, MMMM dd'' }} ({{ Entity.Person.NextBirthDay | HumanizeDateTime }})</strong><br />

        {% if Entity.Person.Email != empty %}
            Email: <a href="mailto:{{ Entity.Person.Email }}">{{ Entity.Person.Email }}</a><br />
        {% endif %}
        
        {% assign mobilePhone = Entity.Person.PhoneNumbers | Where:''NumberTypeValueId'', 136 | Select:''NumberFormatted'' %}
        {% if mobilePhone != empty %}
            Cell: {{ mobilePhone }}<br />
        {% endif %}
        
        {% assign homePhone = Entity.Person.PhoneNumbers | Where:''NumberTypeValueId'', 13 | Select:''NumberFormatted'' %}
        {% if homePhone != empty %}
            Home: {{ homePhone }}<br />
        {% endif %}
        
    </td>
</tr>', 'F3A577DB-8F4A-4245-BD00-0B2B8F789131' )
	IF @AttributeId IS NOT NULL

	BEGIN
		INSERT INTO [AttributeValue] ( [IsSystem], [AttributeId], [EntityId], [Value], [Guid] )
		SELECT 0, @AttributeId, [Id], '5', NEWID()
		FROM [FollowingEventType] WHERE [Guid] = 'E1C2F8BD-E875-4C7B-91A1-EDB98AB01BDC'

		INSERT INTO [AttributeValue] ( [IsSystem], [AttributeId], [EntityId], [Value], [Guid] )
		SELECT 0, @AttributeId, [Id], '0', NEWID()
		FROM [FollowingEventType] WHERE [Guid] = 'F3A577DB-8F4A-4245-BD00-0B2B8F789131'
	END

END

-- Add in family together suggestion
SET @EntityTypeId = ( SELECT TOP 1 [Id] FROM [EntityType] WHERE [Guid] = '20AC7F2A-D42F-438D-93D7-46E3C6769B8F' )
IF @EntityTypeId IS NOT NULL
BEGIN
    INSERT INTO [FollowingSuggestionType] ( [Name], [Description], [ReasonNote], [ReminderDays], [EntityTypeId], [IsActive], [EntityNotificationFormatLava], [Guid] )
	VALUES ( 'Family Members', 'People in the same family', 'Family Member', 30, @EntityTypeId, 1, '', '8641F468-272B-4617-91ED-AB312D0F273C' )
END

-- Event Notification Job
DECLARE @JobId int
INSERT INTO [ServiceJob] ( [IsSystem], [IsActive], [Name], [Description], [Assembly], [Class], [CronExpression], [Guid], [NotificationStatus] )
VALUES ( 0, 0, 'Send Following Event Notification', 'Calculates and sends any following event notices to those that are following the entities that have an event that occurred.',
    '', 'Rock.Jobs.SendFollowingEvents','0 0 7 ? * MON-FRI *','893A745F-8642-4095-9E91-F8C54547DEF0', 3 )
SET @JobId = SCOPE_IDENTITY()

SET @AttributeId = ( SELECT TOP 1 [Id] FROM [Attribute] WHERE [Guid] = '75E0D938-0CA0-4121-B013-D5B7C03BFBB8' )
INSERT INTO [AttributeValue] ( [IsSystem], [AttributeId], [EntityId], [Value], [Guid] )
VALUES ( 0, @AttributeId, @JobId, 'ca7576cd-0a10-4ada-a068-62ee598178f5', NEWID() )

SET @AttributeId = ( SELECT TOP 1 [Id] FROM [Attribute] WHERE [Guid] = '446B2177-76DF-4082-A89E-E18A1B26CCF9' )
INSERT INTO [AttributeValue] ( [IsSystem], [AttributeId], [EntityId], [Value], [Guid] )
VALUES ( 0, @AttributeId, @JobId, '2c112948-ff4c-46e7-981a-0257681eadf4', NEWID() )

-- Suggestion Notification Job
INSERT INTO [ServiceJob] ( [IsSystem], [IsActive], [Name], [Description], [Assembly], [Class], [CronExpression], [Guid], [NotificationStatus] )
VALUES ( 0, 0, 'Send Following Suggestion Notification', 'Calculates and sends any following suggestions to those people that are eligible for following.',
    '', 'Rock.Jobs.SendFollowingSuggestions','0 0 15 ? * MON-FRI *','9C955693-B19C-4A90-9407-7A38450D75FC', 3 )
SET @JobId = SCOPE_IDENTITY()

SET @AttributeId = ( SELECT TOP 1 [Id] FROM [Attribute] WHERE [Guid] = 'E40511EA-3AAD-4C4B-9AB4-33745AD1A00A' )
INSERT INTO [AttributeValue] ( [IsSystem], [AttributeId], [EntityId], [Value], [Guid] )
VALUES ( 0, @AttributeId, @JobId, '8f5a9400-aed2-48a4-b5c8-c9b5d5669f4c', NEWID() )

SET @AttributeId = ( SELECT TOP 1 [Id] FROM [Attribute] WHERE [Guid] = 'B1E268B0-F890-433A-9FED-331CF4D4FD2E' )
INSERT INTO [AttributeValue] ( [IsSystem], [AttributeId], [EntityId], [Value], [Guid] )
VALUES ( 0, @AttributeId, @JobId, '2c112948-ff4c-46e7-981a-0257681eadf4', NEWID() )

-- ** Migration Rollups **

-- MP: Update CalculateGroupRequirement Job to IsSystem=0
UPDATE ServiceJob
SET [IsSystem] = 0
WHERE [Guid] = 'ADC8FE8B-2C7D-46A4-885D-3EBB811DC03F'
AND [IsSystem] = 1

-- JE: Update System Email for Group Requirements Notification
UPDATE [SystemEmail]
SET [Body] = 
'{{ ''Global'' | Attribute:''EmailHeader'' }}

<p>
    {{ Person.NickName }}:
</p>

<p>
    Below are groups that have members with requirements that are either not met or are in a warning state.
</p>


{% for group in GroupsMissingRequirements %}
    {% assign leaderCount = group.Leaders | Size %}
    
    <table style="border: 1px solid #c4c4c4; border-collapse:collapse; mso-table-lspace:0pt; mso-table-rspace:0pt; width: 100%; margin-bottom: 24px;" cellspacing="0" cellpadding="4">
        <tr style="border: 1px solid #c4c4c4;">
            <td colspan="2" bgcolor="#a6a5a5" align="left" style="color: #ffffff; padding: 4px 8px; border: 1px solid #c4c4c4;">
                <h4 style="color: #ffffff; line-height: 1.2em;"><a style="color: #ffffff;" href="{{ ''Global'' | Attribute:''InternalApplicationRoot'' }}Group/{{ group.Id }}">{{ group.Name }}</a> <small>({{ group.GroupTypeName }})</small></h4>
                <small>{{ group.AncestorPathName }}</small> <br />
                <small>{{ ''Leader'' | PluralizeForQuantity:leaderCount }}:</strong> {{ group.Leaders | Map:''FullName'' | Join:'', '' | ReplaceLast:'','','' and'' }}</small> <br />
            </td>
        </tr>
        
        {% for groupMember in group.GroupMembersMissingRequirements %}
            <tr style="border: 1px solid #c4c4c4;">
                <td style="border: 1px solid #c4c4c4; padding: 6px; width: 50%;">
                    {{ groupMember.FullName }} <small>( {{ groupMember.GroupMemberRole }} )</small><br />
                </td>
                <td style="border: 1px solid #c4c4c4; width: 50%;">
                    <table style="width: 100%; margin: 0; border-collapse:collapse; mso-table-lspace:0pt; mso-table-rspace:0pt;" cellspacing="0" cellpadding="4">{% for missingRequirement in groupMember.MissingRequirements -%}
                        {% case missingRequirement.Status -%}
                            {% when ''NotMet'' -%}
                                {% assign messageColor = "#d9534f" -%}
                            {% when ''MeetsWithWarning'' -%}
                                {% assign messageColor = "#f0ad4e" -%}
                        {% endcase -%}<tr><td style="border-bottom: 1px solid #ffffff; color: {{ messageColor }}; padding: 6px;"><small>{{ missingRequirement.Message }} as of {{ missingRequirement.OccurrenceDate | Date:''M/d/yyyy'' }}</small></td></tr>
                    {% endfor -%}</table>
                </td>
            </tr>
        {% endfor %}
    </table>
    &nbsp;

{% endfor %}

<p>&nbsp;</p>

{{ ''Global'' | Attribute:''EmailFooter'' }}'
WHERE [Guid] = '91EA23C3-2E16-2597-4EAF-27C40D3A66D8'

-- JE: Remove checkin type setting from default config
DECLARE @CheckinTypeAttributeId int = (SELECT TOP 1 [Id] FROM [Attribute] WHERE [Guid] = '6CD6EDD9-5DDD-4EAA-9447-A7B61091754D')
DECLARE @AttendanceAnalysisBlockId int = (SELECT TOP 1 [Id] FROM [Block] WHERE [Guid] = '3EF007F1-6B46-4BCD-A435-345C03EBCA17')
DELETE FROM [AttributeValue] WHERE [AttributeId] = @CheckinTypeAttributeId AND [EntityId] = @AttendanceAnalysisBlockId
UPDATE [Attribute] SET [DefaultValue] = null WHERE [Id] = @CheckinTypeAttributeId

-- JE: Add new connection activity 'Called'
DECLARE @InvolvementId int = (SELECT TOP 1 [Id] FROM [ConnectionType] WHERE [Guid] = N'DD565087-A4BE-4943-B123-BF22777E8426')
INSERT [dbo].[ConnectionActivityType] ( [Name], [ConnectionTypeId], [IsActive], [CreatedDateTime], [ModifiedDateTime], [CreatedByPersonAliasId], [ModifiedByPersonAliasId], [Guid], [ForeignId]) 
VALUES ( N'Called', @InvolvementId, 0, getdate(), getdate(), null, null, N'2437D702-E02E-4D8E-48DF-7CEFE4609F35', NULL)

-- DT: Update Family, Known Relationships, and Implied Relationships to ignore the person inactivated
UPDATE [GroupType]
SET [IgnorePersonInactivated] = 1
WHERE [Guid] IN ('790E3215-3B10-442B-AF69-616C0DCB998E','E0C5A0E2-B7B3-4EF4-820D-BBF7F9A374EF','8C0E5852-F08F-4327-9AA5-87800A6AB53E')
