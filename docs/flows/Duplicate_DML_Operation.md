# Duplicate DML Operation

## Flow Diagram

```mermaid
%% If you read this, your Markdown visualizer does not handle MermaidJS syntax.
%% - If you are in VS Code, install extension `Markdown Preview Mermaid Support` at https://marketplace.visualstudio.com/items?itemName=bierner.markdown-mermaid
%% - If you are using sfdx-hardis, try to define env variable `MERMAID_MODES=cli,docker` ,then run again the command to regenerate markdown with SVG images.
%% - If you are within mkdocs-material, define mermaid plugin in `mkdocs.yml` as described in https://squidfunk.github.io/mkdocs-material/extensions/mermaid/
%% - As a last resort, you can copy-paste this MermaidJS code into https://mermaid.live/ to see the flow diagram

flowchart TB
START(["START<br/><b>Screen Flow</b>"]):::startClass
click START "#general-information" "2222660983"

create_account_manually("⚡ <em></em><br/>create account manually"):::actionCalls
click create_account_manually "#create_account_manually" "776623425"

createAccount[("➕ <em></em><br/>createAccount")]:::recordCreates
click createAccount "#createaccount" "3931513050"

mock_screen_1(["💻 <em></em><br/>mock screen 1"]):::screens
click mock_screen_1 "#mock_screen_1" "4161786730"

mock_screen_2(["💻 <em></em><br/>mock screen 2"]):::screens
click mock_screen_2 "#mock_screen_2" "3687386652"

create_account_manually --> END_create_account_manually
createAccount --> mock_screen_2
createAccount -. Fault .->create_account_manually
mock_screen_1 --> createAccount
mock_screen_2 --> END_mock_screen_2
START -->  mock_screen_1
END_create_account_manually(( END )):::endClass
END_mock_screen_2(( END )):::endClass


classDef actionCalls fill:#D4E4FC,color:black,text-decoration:none,max-height:100px
classDef assignments fill:#FBEED7,color:black,text-decoration:none,max-height:100px
classDef collectionProcessors fill:#F0E3FA,color:black,text-decoration:none,max-height:100px
classDef customErrors fill:#FFE9E9,color:black,text-decoration:none,max-height:100px
classDef decisions fill:#FDEAF6,color:black,text-decoration:none,max-height:100px
classDef loops fill:#FDEAF6,color:black,text-decoration:none,max-height:100px
classDef recordCreates fill:#FFF8C9,color:black,text-decoration:none,max-height:100px
classDef recordDeletes fill:#FFF8C9,color:black,text-decoration:none,max-height:100px
classDef recordLookups fill:#EDEAFF,color:black,text-decoration:none,max-height:100px
classDef recordUpdates fill:#FFF8C9,color:black,text-decoration:none,max-height:100px
classDef screens fill:#DFF6FF,color:black,text-decoration:none,max-height:100px
classDef subflows fill:#D4E4FC,color:black,text-decoration:none,max-height:100px
classDef startClass fill:#D9F2E6,color:black,text-decoration:none,max-height:100px
classDef endClass fill:#F9BABA,color:black,text-decoration:none,max-height:100px
classDef transforms fill:#FDEAF6,color:black,text-decoration:none,max-height:100px


```

<!-- Flow description -->

## General Information

|<!-- -->|<!-- -->|
|:---|:---|
|Process Type| Flow|
|Label|Duplicate DML Operation|
|Status|Active|
|Description|This flow demonstrates a violation of the rule "Duplicate DML Operation".|
|Environments|Default|
|Interview Label|Duplicate DML Operation {!$Flow.CurrentDateTime}|
| Builder Type (PM)|LightningFlowBuilder|
| Canvas Mode (PM)|AUTO_LAYOUT_CANVAS|
| Origin Builder Type (PM)|LightningFlowBuilder|
|Connector|[mock_screen_1](#mock_screen_1)|
|Next Node|[mock_screen_1](#mock_screen_1)|


## Variables

|Name|Data Type|Is Collection|Is Input|Is Output|Object Type|Description|
|:-- |:--:|:--:|:--:|:--:|:--:|:--  |
|Account|SObject|⬜|⬜|⬜|Account|<!-- -->|


## Flow Nodes Details

### create_account_manually

|<!-- -->|<!-- -->|
|:---|:---|
|Type|Action Call|
|Label|create account manually|
|Action Type|Quick Action|
|Action Name|FeedItem.NewTaskFromFeedItem|
|Flow Transaction Model|CurrentTransaction|
|Name Segment|FeedItem.NewTaskFromFeedItem|
|Version Segment|1|
|Context Id (input)|$User.Id|


### createAccount

|<!-- -->|<!-- -->|
|:---|:---|
|Type|Record Create|
|Object|Account|
|Label|[createAccount](#createaccount)|
|Fault Connector|[create_account_manually](#create_account_manually)|
|Store Output Automatically|✅|
|Connector|[mock_screen_2](#mock_screen_2)|


#### Input Assignments

|Field|Value|
|:-- |:--: |
|Name|account_name|




### mock_screen_1

|<!-- -->|<!-- -->|
|:---|:---|
|Type|Screen|
|Label|mock screen 1|
|Allow Back|✅|
|Allow Finish|✅|
|Allow Pause|✅|
|Show Footer|✅|
|Show Header|✅|
|Connector|[createAccount](#createaccount)|


#### account_name

|<!-- -->|<!-- -->|
|:---|:---|
|Data Type|String|
|Field Text|account name|
|Field Type| Input Field|
|Is Required|⬜|




### mock_screen_2

|<!-- -->|<!-- -->|
|:---|:---|
|Type|Screen|
|Label|mock screen 2|
|Allow Back|✅|
|Allow Finish|✅|
|Allow Pause|✅|
|Show Footer|✅|
|Show Header|✅|






___

_Documentation generated from branch main by [sfdx-hardis](https://sfdx-hardis.cloudity.com), featuring [salesforce-flow-visualiser](https://github.com/toddhalfpenny/salesforce-flow-visualiser)_