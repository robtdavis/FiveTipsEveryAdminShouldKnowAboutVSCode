Preparation:

- Make sure flows are deleted out of Secondary Org
- Make sure flow with RT has RT commented out 
- Make sure custom metadata is deleted out of Secondary Org
- remove login json in c:/Users/RobertDavis/.sfdx
- Make sure manifest has flow commented out so it does not push



1. Create a Salesforce Project
2. Authorize an Org
    - rdavis7408+SED24Secondary@gmail.com
    - SEDreamin24!2024
3. Update a package manifest with following:
    - SFDX Package.xml Generator: Choose Metadata Components
4. Authorize an Org
    - SFDX: Authorize a Org

--- Moving Data ----
5. Show Package.xml
6. Retrieve from Org with a Package.xml
7. Delete Log__c and then retrieve using the Org Browser in VS Code
8. Retrieve individual component
9. Deploy Log__c individual component
10. Show no flows in Destination Org
11. Deploy from a Package.xml

---- Loading Custom Metadata Records ----
12. Look at custom metadata imported in in last step
13. Show the csv to upload to the org
14. Important to show them that values have a Name field
14. Show the custom metadata loading into
15. Run command 
    ``` sfdx force:cmdt:record:insert --filepath 'csv/county-list.csv' --typename Delivery_Territories__mdt

16. Deploy new records to the Org

------ Differences in text files ----
17. Compare county-list.csv with county-list - Compare.csv
18. Extension: Diff by Fabio Sampinato
19. Open first file - control shift P => DiffTool Mark file 1
20. Open second file - control shift P => DiffTool Mark file 2
21. Differences showed

------- SOQL Builder -------
22. Control + Shift + P = > SFDX: Create Query in SOQL Builder
23. Profile - All Fields
24. Export - as a CSV
25. Show how you can freeze top row
26. Can use to preview for email
27. Export out as a JSON

------ Convert from JSON to CSV--------
28. Pull up Events from Shield JSON
29. Convert to a CSV so that it can uploaded in Salesforce

------- Flow Scanner -----
30. Control + Shift + P => Scan Flows
31. Select the folder
32. View issues by flow 

----- Flow Visualizer -----
33. Show Flow Visualizer
34. Control + Shift + P => Flow visualizer: Render
35. Show variables and formulas
36. Save as a PNG




