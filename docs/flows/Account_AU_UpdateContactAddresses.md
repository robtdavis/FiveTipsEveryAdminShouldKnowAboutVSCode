# Account_AU_UpdateContactAddresses

## Flow Diagram

```mermaid
%% If you read this, your Markdown visualizer does not handle MermaidJS syntax.
%% - If you are in VS Code, install extension `Markdown Preview Mermaid Support` at https://marketplace.visualstudio.com/items?itemName=bierner.markdown-mermaid
%% - If you are using sfdx-hardis, try to define env variable `MERMAID_MODES=cli,docker` ,then run again the command to regenerate markdown with SVG images.
%% - If you are within mkdocs-material, define mermaid plugin in `mkdocs.yml` as described in https://squidfunk.github.io/mkdocs-material/extensions/mermaid/
%% - As a last resort, you can copy-paste this MermaidJS code into https://mermaid.live/ to see the flow diagram

flowchart TB
START(["START<br/><b>AutoLaunched Flow</b></br>Type: <b> Record After Save</b>"]):::startClass
click START "#general-information" "3631746289"

UPDATE_Related_Contact_Addresses[("🛠️ <em></em><br/>UPDATE_Related_Contact_Addresses")]:::recordUpdates
click UPDATE_Related_Contact_Addresses "#update_related_contact_addresses" "775584392"

UPDATE_Related_Contact_Addresses --> END_UPDATE_Related_Contact_Addresses
START -->  UPDATE_Related_Contact_Addresses
END_UPDATE_Related_Contact_Addresses(( END )):::endClass


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
|Object|Account|
|Process Type| Auto Launched Flow|
|Trigger Type| Record After Save|
|Record Trigger Type| Update|
|Label|Account_AU_UpdateContactAddresses|
|Status|Active|
|Description|Update the Contact Addresses to match the business address|
|Environments|Default|
|Interview Label|Account_AU_UpdateContactAddresses {!$Flow.CurrentDateTime}|
| Builder Type (PM)|LightningFlowBuilder|
| Canvas Mode (PM)|AUTO_LAYOUT_CANVAS|
| Origin Builder Type (PM)|LightningFlowBuilder|
|Connector|[UPDATE_Related_Contact_Addresses](#update_related_contact_addresses)|
|Next Node|[UPDATE_Related_Contact_Addresses](#update_related_contact_addresses)|


## Flow Nodes Details

### UPDATE_Related_Contact_Addresses

|<!-- -->|<!-- -->|
|:---|:---|
|Type|Record Update|
|Label|[UPDATE_Related_Contact_Addresses](#update_related_contact_addresses)|
|Description|update Acct Shipping Address to Contact Mailing Address|
|Input Reference|$Record.Contacts|


#### Input Assignments

|Field|Value|
|:-- |:--: |
|MailingCity|$Record.ShippingCity|
|MailingCountry|$Record.ShippingCountry|
|MailingPostalCode|$Record.ShippingPostalCode|
|MailingState|$Record.ShippingState|
|MailingStreet|$Record.ShippingStreet|








___

_Documentation generated from branch main by [sfdx-hardis](https://sfdx-hardis.cloudity.com), featuring [salesforce-flow-visualiser](https://github.com/toddhalfpenny/salesforce-flow-visualiser)_