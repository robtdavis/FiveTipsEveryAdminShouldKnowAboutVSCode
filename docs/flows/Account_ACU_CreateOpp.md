# Account_ACU_CreateOpp

## Flow Diagram

![diagram](./Account_ACU_CreateOpp-1.svg)

<!-- Flow description -->

## General Information

|<!-- -->|<!-- -->|
|:---|:---|
|Process Type| Auto Launched Flow|
|Label|Account_ACU_CreateOpp|
|Status|Active|
|Description|Create Opportunity for Account|
|Environments|Default|
|Interview Label|Account_ACU_CreateOpp {!$Flow.CurrentDateTime}|
| Builder Type (PM)|LightningFlowBuilder|
| Canvas Mode (PM)|AUTO_LAYOUT_CANVAS|
| Origin Builder Type (PM)|LightningFlowBuilder|
|Connector|[GET_Account](#get_account)|
|Next Node|[GET_Account](#get_account)|


## Variables

|Name|Data Type|Is Collection|Is Input|Is Output|Object Type|Description|
|:-- |:--:|:--:|:--:|:--:|:--:|:--  |
|recordId|String|⬜|✅|⬜|<!-- -->|<!-- -->|


## Formulas

|Name|Data Type|Expression|Description|
|:-- |:--:|:-- |:--  |
|varOppname|String|{!GET_Account.Name} &'-'&TEXT({!$System.OriginDateTime})|<!-- -->|


## Flow Nodes Details

### Create_Opportunity_Great_Merchandise

|<!-- -->|<!-- -->|
|:---|:---|
|Type|Record Lookup|
|Object|Opportunity|
|Label|Create Opportunity - Great Merchandise|
|Assign Null Values If No Records Found|⬜|
|Get First Record Only|✅|
|Store Output Automatically|✅|


#### Filters (logic: **and**)

|Filter Id|Field|Operator|Value|
|:-- |:-- |:--:|:--: |
|1|StageName| Equal To|Prospecting|
|2|Amount| Equal To|10000|
|3|Name| Equal To|varOppname|




### GET_Account

|<!-- -->|<!-- -->|
|:---|:---|
|Type|Record Lookup|
|Object|Account|
|Label|[GET_Account](#get_account)|
|Assign Null Values If No Records Found|⬜|
|Get First Record Only|✅|
|Store Output Automatically|✅|
|Connector|[Create_Opportunity_Great_Merchandise](#create_opportunity_great_merchandise)|


#### Filters (logic: **and**)

|Filter Id|Field|Operator|Value|
|:-- |:-- |:--:|:--: |
|1|Id| Equal To|recordId|








___

_Documentation generated from branch dev by [sfdx-hardis](https://sfdx-hardis.cloudity.com), featuring [salesforce-flow-visualiser](https://github.com/toddhalfpenny/salesforce-flow-visualiser)_