@description('The friendly name for the workbook that is used in the Gallery or Saved List.  This name must be unique within a resource group.')
param workbookDisplayName string = 'Microsoft Purview DLP Incident Management'

@description('The gallery that the workbook will been shown under. Supported values include workbook, tsg, etc. Usually, this is \'workbook\'')
param workbookType string = 'sentinel'

@description('The id of resource instance to which the workbook will be associated')
param workbookSourceId string

@description('The unique guid for this workbook instance')
param workbookId string = newGuid()

resource workbookIncidentManagement 'microsoft.insights/workbooks@2022-04-01' = {
  name: workbookId
  location: resourceGroup().location
  kind: 'shared'
  properties: {
    displayName: workbookDisplayName
    serializedData: '{"version":"Notebook/1.0","items":[{"type":1,"content":{"json":"## Microsoft Purview DLP Incident Management"},"name":"text - 2"},{"type":9,"content":{"version":"KqlParameterItem/1.0","parameters":[{"id":"264afe85-711d-483d-a208-af021b3fcfc2","version":"KqlParameterItem/1.0","name":"paramWorkspace","label":"Sentinel Workspace","type":5,"isRequired":true,"query":"resources\\r\\n| where type contains \\"microsoft.operationalinsights/workspaces\\"\\r\\n| extend id = tolower(id)\\r\\n| summarize by id=tolower(id)\\r\\n| project id","crossComponentResources":["value::all"],"typeSettings":{"additionalResourceOptions":[],"showDefault":false},"queryType":1,"value":"/subscriptions/46db4fa1-a60c-4cbd-be28-807c0c4ea04f/resourcegroups/rg-dlp11/providers/microsoft.operationalinsights/workspaces/sentinel11"},{"id":"b8b136a2-f4bf-42c8-babc-902b8ff6cc6d","version":"KqlParameterItem/1.0","name":"paramTimeRange","label":"Incident Modified Time","type":4,"isRequired":true,"typeSettings":{"selectableValues":[{"durationMs":300000},{"durationMs":900000},{"durationMs":1800000},{"durationMs":3600000},{"durationMs":14400000},{"durationMs":43200000},{"durationMs":86400000},{"durationMs":172800000},{"durationMs":259200000},{"durationMs":604800000},{"durationMs":1209600000},{"durationMs":2419200000},{"durationMs":2592000000},{"durationMs":5184000000},{"durationMs":7776000000}],"allowCustom":true},"value":{"durationMs":7776000000}},{"id":"c10ac340-1c5d-4273-8d4f-04aeb6f7736d","version":"KqlParameterItem/1.0","name":"paramProduct","label":"Product","type":2,"multiSelect":true,"quote":"\'","delimiter":",","query":"SecurityIncident\\r\\n| where TimeGenerated {paramTimeRange} and Status != \'Deleted\'\\r\\n| extend Product = tostring(parse_json(tostring(AdditionalData.alertProductNames))[0])\\r\\n| summarize Count=count(IncidentNumber) by Product = case (Product ==\\"\\", \\"Undefined\\", Product)\\r\\n| project Value = Product, Label = Product, Selected = iff(Product == \'Microsoft Data Loss Prevention (Custom)\', true, false) ","crossComponentResources":["{paramWorkspace}"],"isHiddenWhenLocked":true,"typeSettings":{"additionalResourceOptions":["value::all"],"showDefault":false},"queryType":0,"resourceType":"microsoft.operationalinsights/workspaces"},{"id":"79d64d60-f4ed-4ed4-ab93-de72d0ee74a5","version":"KqlParameterItem/1.0","name":"paramStatus","label":"Incident Status","type":2,"multiSelect":true,"quote":"\'","delimiter":",","typeSettings":{"additionalResourceOptions":["value::all"],"selectAllValue":"all","showDefault":false},"jsonData":"[\\r\\n    {\\"value\\": \\"New\\", \\"selected\\": true}, \\r\\n    {\\"value\\": \\"Active\\", \\"selected\\": true},\\r\\n    {\\"value\\": \\"Closed\\", \\"selected\\": false}\\r\\n]","timeContext":{"durationMs":7776000000},"timeContextFromParameter":"paramTimeRange","value":["New","Active"]},{"id":"75803958-4d09-442e-a143-4005d267d0d7","version":"KqlParameterItem/1.0","name":"paramClassification","label":"Incident Classification","type":2,"multiSelect":true,"quote":"\'","delimiter":",","query":"let product = dynamic([{paramProduct}]);\\r\\n\\r\\nSecurityIncident\\r\\n| where TimeGenerated {paramTimeRange} and Status != \'Deleted\'\\r\\n| extend Product = todynamic((parse_json(tostring(AdditionalData.alertProductNames))[0]))\\r\\n| where Product in (product) or \\"*\\" in (product)\\r\\n| summarize by Classification\\r\\n| where Classification != \'\'","crossComponentResources":["{paramWorkspace}"],"typeSettings":{"additionalResourceOptions":["value::all"],"selectAllValue":"all","showDefault":false},"timeContext":{"durationMs":0},"timeContextFromParameter":"paramTimeRange","defaultValue":"value::all","queryType":0,"resourceType":"microsoft.operationalinsights/workspaces"},{"id":"17aca97f-01e3-4012-ac2c-8167f6a4353b","version":"KqlParameterItem/1.0","name":"paramWorkload","label":"Workload","type":2,"multiSelect":true,"quote":"\'","delimiter":",","query":"let product = dynamic([{paramProduct}]);\\r\\n\\r\\nSecurityIncident\\r\\n| where TimeGenerated {paramTimeRange} and Status != \'Deleted\'\\r\\n| extend Product = todynamic((parse_json(tostring(AdditionalData.alertProductNames))[0]))\\r\\n| where Product in (product) or \\"*\\" in (product)\\r\\n| summarize arg_max(TimeGenerated, *) by IncidentNumber\\r\\n| mv-expand AlertIds\\r\\n| extend AlertId = tostring(AlertIds)\\r\\n| join kind=leftouter (SecurityAlert | where TimeGenerated {paramTimeRange} | summarize arg_max(TimeGenerated, *) by SystemAlertId) on $left.AlertId == $right.SystemAlertId\\r\\n| extend Workload = parse_json(tostring(parse_json(ExtendedProperties).[\\"Custom Details\\"])).Workload[0]\\r\\n| summarize by tostring(Workload), Label = iff(Workload == \'MicrosoftTeams\', \'Microsoft Teams\', Workload)\\r\\n| where Workload != \'\'","crossComponentResources":["{paramWorkspace}"],"typeSettings":{"additionalResourceOptions":["value::all"],"selectAllValue":"all","showDefault":false},"defaultValue":"value::all","queryType":0,"resourceType":"microsoft.operationalinsights/workspaces"},{"id":"c9768571-fcde-4d64-9a1b-f8339e6f21a7","version":"KqlParameterItem/1.0","name":"paramMatchCount","label":"Match Count GTE","type":1,"query":"print(\'0\')","typeSettings":{"paramValidationRules":[{"regExp":"/^\\\\d+$/","match":false,"message":"Please provide a number value."}]},"queryType":0,"resourceType":"microsoft.operationalinsights/workspaces"},{"id":"38428091-9cd9-423f-aa0c-b67f4129e807","version":"KqlParameterItem/1.0","name":"paramSubscriptionId","type":1,"query":"let workspaceId = datatable(data:string) [\'{paramWorkspace}\'];\\r\\n\\r\\nworkspaceId\\r\\n| extend SubscriptionId = split(data, \'/\')[2]\\r\\n| project SubscriptionId","crossComponentResources":["{paramWorkspace}"],"isHiddenWhenLocked":true,"queryType":0,"resourceType":"microsoft.resources/subscriptions"},{"id":"3a92ac27-d518-486c-b521-0c19b0cc2542","version":"KqlParameterItem/1.0","name":"paramRgName","type":1,"query":"let workspaceId = datatable(data:string) [\'{paramWorkspace}\'];\\r\\n\\r\\nworkspaceId\\r\\n| extend RgName = split(data, \'/\')[4]\\r\\n| project RgName","crossComponentResources":["{paramWorkspace}"],"isHiddenWhenLocked":true,"queryType":0,"resourceType":"microsoft.resources/resourcegroups"}],"style":"pills","queryType":0,"resourceType":"microsoft.operationalinsights/workspaces"},"name":"parametersMain"},{"type":9,"content":{"version":"KqlParameterItem/1.0","parameters":[{"id":"99d21c0f-2d6c-40a7-a8ad-eb3ec663f544","version":"KqlParameterItem/1.0","name":"paramIncidents","type":1,"query":"{\\"version\\":\\"ARMEndpoint/1.0\\",\\"data\\":null,\\"headers\\":[],\\"method\\":\\"GET\\",\\"path\\":\\"/subscriptions/{paramSubscriptionId}/resourceGroups/{paramRgName}/providers/Microsoft.OperationalInsights/workspaces/{paramWorkspace:label}/providers/Microsoft.SecurityInsights/incidents?api-version=2023-05-01-preview&$orderby=properties/lastModifiedTimeUtc desc&$top=1000&$filter=properties/lastModifiedTimeUtc gt {paramTimeRange:startISO}\\",\\"urlParams\\":[],\\"batchDisabled\\":false,\\"transformers\\":[{\\"type\\":\\"jsonpath\\"}]}","timeContext":{"durationMs":86400000},"queryType":12}],"style":"pills","queryType":12},"conditionalVisibility":{"parameterName":"paramWorkspace","comparison":"isEqualTo","value":"67585678"},"name":"parametersHidden"},{"type":3,"content":{"version":"KqlItem/1.0","query":"let status = dynamic([{paramStatus}]);\\r\\nlet classification = dynamic([{paramClassification}]);\\r\\nlet workload = dynamic([{paramWorkload}]);\\r\\nlet product = dynamic([{paramProduct}]);\\r\\nlet matchCountTrigger = {paramMatchCount};\\r\\n\\r\\nlet data = SecurityIncident\\r\\n| where TimeGenerated {paramTimeRange}\\r\\n| extend Product = todynamic((parse_json(tostring(AdditionalData.alertProductNames))[0]))\\r\\n| where Product in (product) or \\"*\\" in (product)\\r\\n| summarize arg_max(TimeGenerated, *) by IncidentNumber\\r\\n| where Status in (status) or \'all\' in (status) \\r\\n| where Classification in (classification) or \'all\' in (classification)\\r\\n| summarize arg_max(TimeGenerated, *) by IncidentNumber\\r\\n| mv-expand AlertIds\\r\\n| extend AlertId = tostring(AlertIds)\\r\\n| join kind=leftouter (SecurityAlert | where TimeGenerated {paramTimeRange} | summarize arg_max(TimeGenerated, *) by SystemAlertId\\r\\n    | extend EventId = substring(AlertLink, indexof(AlertLink, \'eventid=\') + 8, indexof(AlertLink, \'&creationtime\') - indexof(AlertLink, \'eventid=\') - 8)\\r\\n    | extend Workload = tostring(parse_json(tostring(parse_json(ExtendedProperties).[\\"Custom Details\\"])).Workload[0])\\r\\n    | extend User = tostring(parse_json(tostring(parse_json(ExtendedProperties).[\\"Custom Details\\"])).User[0])\\r\\n    | extend Actions = tostring(parse_json(tostring(parse_json(ExtendedProperties).[\\"Custom Details\\"])).ActionsTaken[0])\\r\\n    | extend MatchCount = tostring(parse_json(tostring(parse_json(ExtendedProperties).[\\"Custom Details\\"])).MatchCount[0])\\r\\n    | extend PolicyName = AlertName\\r\\n    | extend AlertStatus = Status) on $left.AlertId == $right.SystemAlertId\\r\\n| extend IncidentNumber = tostring(IncidentNumber)\\r\\n| extend IncidentArmId = strcat(\'{paramWorkspace}/providers/Microsoft.SecurityInsights/Incidents/\', IncidentName)\\r\\n| where Workload in (workload) or \'all\' in (workload)\\r\\n| where toint(MatchCount) >= matchCountTrigger\\r\\n| order by TimeGenerated;\\r\\n\\r\\ndata\\r\\n| summarize arg_max(TimeGenerated, *), Count = count() by SystemAlertId\\r\\n| project Type = \'Alert\', ID = int(null), Title = AlertName, CreatedTime = StartTime, LastUpdateTime = ProcessingEndTime, IdField = strcat(IncidentNumber, \'/\', SystemAlertId), Parent = IncidentNumber, Status = AlertStatus, Owner = \'\', Severity = AlertSeverity, Link = AlertLink, Workload, MatchCount, User, Actions, IncidentArmId\\r\\n| union (data\\r\\n    | summarize Count = count(), MatchCount = tostring(max(toint(MatchCount))), User = tostring(count_distinct(User)), Workload = tostring(count_distinct(Workload)), arg_max(TimeGenerated, *) by IncidentNumber\\r\\n    | project Type = \'Incident\', ID = toint(IncidentNumber), Title, CreatedTime, LastUpdateTime = LastModifiedTime, IdField = IncidentNumber, Owner = iff(Owner.assignedTo == \'\', \'Unassigned\', tostring(Owner.assignedTo)), Status, Parent = \'\', Severity = strcat(\'(\', Count, \') \', Severity), Workload = strcat(\'(\', Workload, \')\'), Link = IncidentUrl, User = strcat(\'(\', User, \')\'), MatchCount, IncidentArmId)\\r\\n| order by LastUpdateTime\\r\\n\\r\\n\\r\\n","size":3,"title":"DLP Incidents","timeContextFromParameter":"paramTimeRange","queryType":0,"resourceType":"microsoft.operationalinsights/workspaces","crossComponentResources":["{paramWorkspace}"],"gridSettings":{"formatters":[{"columnMatch":"ID","formatter":7,"formatOptions":{"linkTarget":"OpenBlade","bladeOpenContext":{"bladeName":"IncidentPage.ReactView","extensionName":"Microsoft_Azure_Security_Insights","bladeParameters":[{"name":"incidentArmId","source":"column","value":"IncidentArmId"}]}}},{"columnMatch":"IdField","formatter":5},{"columnMatch":"Parent","formatter":5},{"columnMatch":"Title","formatter":7,"formatOptions":{"linkTarget":"OpenBlade","linkIsContextBlade":true,"bladeOpenContext":{"bladeName":"IncidentPage.ReactView","extensionName":"Microsoft_Azure_Security_Insights","bladeParameters":[{"name":"incidentArmId","source":"column","value":"IncidentArmId"}]}}},{"columnMatch":"Severity","formatter":18,"formatOptions":{"thresholdsOptions":"icons","thresholdsGrid":[{"operator":"contains","thresholdValue":"High","representation":"Sev0","text":"{0}{1}"},{"operator":"contains","thresholdValue":"Medium","representation":"Sev1","text":"{0}{1}"},{"operator":"contains","thresholdValue":"Low","representation":"Sev2","text":"{0}{1}"},{"operator":"contains","thresholdValue":"Informational","representation":"Sev3","text":"{0}{1}"},{"operator":"Default","thresholdValue":null,"representation":"Sev0","text":"{0}{1}"}]}},{"columnMatch":"Link","formatter":5,"formatOptions":{"linkTarget":"Url","linkLabel":"Open"}},{"columnMatch":"IncidentArmId","formatter":5}],"rowLimit":10000,"hierarchySettings":{"idColumn":"IdField","parentColumn":"Parent","treeType":0,"expanderColumn":"Severity"},"sortBy":[{"itemKey":"CreatedTime","sortOrder":2}],"labelSettings":[{"columnId":"CreatedTime","label":"Created Time"},{"columnId":"LastUpdateTime","label":"Last Update Time"},{"columnId":"Workload","label":"Workloads"},{"columnId":"MatchCount","label":"Match Count"},{"columnId":"User","label":"Users"}]},"sortBy":[{"itemKey":"CreatedTime","sortOrder":2}]},"conditionalVisibility":{"parameterName":"paramWorkspace","comparison":"isEqualTo","value":"999999999999"},"name":"queryDlpAlertsOld"},{"type":3,"content":{"version":"KqlItem/1.0","query":"let status = dynamic([{paramStatus}]);\\r\\nlet classification = dynamic([{paramClassification}]);\\r\\nlet workload = dynamic([{paramWorkload}]);\\r\\nlet product = dynamic([{paramProduct}]);\\r\\nlet matchCountTrigger = {paramMatchCount};\\r\\n\\r\\nlet IncidentData = datatable(data:string) [\'{paramIncidents}\'];\\r\\n\\r\\nlet Incidents = IncidentData\\r\\n| extend replace = replace_string(data, \'\\"\\"\', \'\\"\')\\r\\n| extend json = parse_json(replace)\\r\\n| mv-expand json\\r\\n| extend IncidentNumber = tostring(parse_json(tostring(json.properties)).incidentNumber)\\r\\n| extend Title = tostring(parse_json(tostring(json.properties)).[\\"title\\"])\\r\\n| extend Status = tostring(parse_json(tostring(json.properties)).status)\\r\\n| extend Classification = tostring(parse_json(tostring(json.properties)).classification)\\r\\n| extend Severity = tostring(parse_json(tostring(json.properties)).severity)\\r\\n| extend IncidentUrl = tostring(parse_json(tostring(json.properties)).incidentUrl)\\r\\n| extend Owner = tostring(parse_json(tostring(json.properties)).owner.assignedTo)\\r\\n| extend IncidentName = tostring(json.name)\\r\\n| extend CreatedTime = todatetime(parse_json(tostring(json.properties)).createdTimeUtc)\\r\\n| extend LastModifiedTime = todatetime(parse_json(tostring(json.properties)).lastModifiedTimeUtc)\\r\\n| extend Product = tostring(parse_json(tostring(parse_json(tostring(parse_json(tostring(json.properties)).additionalData)).alertProductNames))[0])\\r\\n| where Product in (product) or \\"*\\" in (product)\\r\\n| where Status in (status) or \'all\' in (status) \\r\\n| where Classification in (classification) or \'all\' in (classification)\\r\\n| join kind=leftouter (SecurityIncident | where TimeGenerated {paramTimeRange} | summarize arg_max(TimeGenerated, *) by tostring(IncidentNumber)) on IncidentNumber\\r\\n| mv-expand AlertIds\\r\\n| extend AlertId = tostring(AlertIds)\\r\\n| join kind=leftouter (SecurityAlert | where TimeGenerated {paramTimeRange} | summarize arg_max(TimeGenerated, *) by SystemAlertId\\r\\n    | extend EventId = substring(AlertLink, indexof(AlertLink, \'eventid=\') + 8, indexof(AlertLink, \'&creationtime\') - indexof(AlertLink, \'eventid=\') - 8)\\r\\n    | extend Workload = tostring(parse_json(tostring(parse_json(ExtendedProperties).[\\"Custom Details\\"])).Workload[0])\\r\\n    | extend User = tostring(parse_json(tostring(parse_json(ExtendedProperties).[\\"Custom Details\\"])).User[0])\\r\\n    | extend Actions = tostring(parse_json(tostring(parse_json(ExtendedProperties).[\\"Custom Details\\"])).ActionsTaken[0])\\r\\n    | extend MatchCount = tostring(parse_json(tostring(parse_json(ExtendedProperties).[\\"Custom Details\\"])).MatchCount[0])\\r\\n    | extend PolicyName = AlertName\\r\\n    | extend AlertStatus = Status) on $left.AlertId == $right.SystemAlertId\\r\\n| extend IncidentArmId = strcat(\'{paramWorkspace}/providers/Microsoft.SecurityInsights/Incidents/\', IncidentName)\\r\\n| where Workload in (workload) or \'all\' in (workload)\\r\\n| where toint(MatchCount) >= matchCountTrigger;\\r\\n\\r\\nIncidents\\r\\n| summarize arg_max(TimeGenerated, *), Count = count() by SystemAlertId\\r\\n| project Type = \'Alert\', ID = int(null), Title = AlertName, CreatedTime = StartTime, LastUpdateTime = ProcessingEndTime, IdField = strcat(IncidentNumber, \'/\', SystemAlertId), Parent = IncidentNumber, Status = AlertStatus, Owner = \'\', Severity = AlertSeverity, Link = AlertLink, Workload, MatchCount, User, Actions, IncidentArmId\\r\\n| union (Incidents\\r\\n    | summarize Count = count(), MatchCount = tostring(max(toint(MatchCount))), User = tostring(count_distinct(User)), Workload = tostring(count_distinct(Workload)), arg_max(TimeGenerated, *) by IncidentNumber\\r\\n    | project Type = \'Incident\', ID = toint(IncidentNumber), Title, CreatedTime, LastUpdateTime = LastModifiedTime, IdField = IncidentNumber, Owner = iff(Owner == \'\', \'Unassigned\', tostring(Owner)), Status, Parent = \'\', Severity = strcat(\'(\', Count, \') \', Severity), Workload = strcat(\'(\', Workload, \')\'), Link = IncidentUrl, User = strcat(\'(\', User, \')\'), MatchCount, IncidentArmId)\\r\\n| order by LastUpdateTime\\r\\n\\r\\n\\r\\n","size":3,"title":"DLP Incidents","timeContextFromParameter":"paramTimeRange","queryType":0,"resourceType":"microsoft.operationalinsights/workspaces","crossComponentResources":["{paramWorkspace}"],"gridSettings":{"formatters":[{"columnMatch":"ID","formatter":7,"formatOptions":{"linkTarget":"OpenBlade","bladeOpenContext":{"bladeName":"IncidentPage.ReactView","extensionName":"Microsoft_Azure_Security_Insights","bladeParameters":[{"name":"incidentArmId","source":"column","value":"IncidentArmId"}]}}},{"columnMatch":"IdField","formatter":5},{"columnMatch":"Parent","formatter":5},{"columnMatch":"Title","formatter":7,"formatOptions":{"linkTarget":"OpenBlade","linkIsContextBlade":true,"bladeOpenContext":{"bladeName":"IncidentPage.ReactView","extensionName":"Microsoft_Azure_Security_Insights","bladeParameters":[{"name":"incidentArmId","source":"column","value":"IncidentArmId"}]}}},{"columnMatch":"Severity","formatter":18,"formatOptions":{"thresholdsOptions":"icons","thresholdsGrid":[{"operator":"contains","thresholdValue":"High","representation":"Sev0","text":"{0}{1}"},{"operator":"contains","thresholdValue":"Medium","representation":"Sev1","text":"{0}{1}"},{"operator":"contains","thresholdValue":"Low","representation":"Sev2","text":"{0}{1}"},{"operator":"contains","thresholdValue":"Informational","representation":"Sev3","text":"{0}{1}"},{"operator":"Default","thresholdValue":null,"representation":"Sev0","text":"{0}{1}"}]}},{"columnMatch":"Link","formatter":5,"formatOptions":{"linkTarget":"Url","linkLabel":"Open"}},{"columnMatch":"IncidentArmId","formatter":5}],"rowLimit":10000,"hierarchySettings":{"idColumn":"IdField","parentColumn":"Parent","treeType":0,"expanderColumn":"Severity"},"sortBy":[{"itemKey":"LastUpdateTime","sortOrder":2}],"labelSettings":[{"columnId":"CreatedTime","label":"Created Time"},{"columnId":"LastUpdateTime","label":"Last Update Time"},{"columnId":"Workload","label":"Workloads"},{"columnId":"MatchCount","label":"Match Count"},{"columnId":"User","label":"Users"}]},"sortBy":[{"itemKey":"LastUpdateTime","sortOrder":2}]},"name":"queryDlpIncidents"}],"isLocked":false,"fallbackResourceIds":["/subscriptions/46db4fa1-a60c-4cbd-be28-807c0c4ea04f/resourcegroups/rg-dlp11/providers/microsoft.operationalinsights/workspaces/sentinel11"],"fromTemplateId":"sentinel-UserWorkbook"}'
    version: '1.0'
    sourceId: workbookSourceId
    category: workbookType
  }
  dependsOn: []
}
