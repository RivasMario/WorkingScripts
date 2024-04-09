Terms 

RecordId 
Unique identifier of a logged in session. This GUID will be different for each user and for each session. For an example of how to find the RecordId see here 

Description of tables: 

ConnectionEvents 

Data about login, logout, rdp connection, rdp disconnect events 

Example: Find session events for a given user between two times 

ConnectionEvents 
| where UserName == "testUsername" 
| where Timestamp between (datetime(2021-03-20) .. datetime(2021-03-30)) 

Example: Find last 3 login events for a user 

ConnectionEvents 
| order by Timestamp desc 
| where UserName contains "user" 
| where Event == "SessionLogon" 
| take 3 

ClipboardEvents 
Copy/cut or paste events and contents 

Exceptions 
ESM agent exceptions recorded 

HealthStatus 
ESM agent self health check data 

OcrRestults 
For use in a future feature 

Predictions 
For use in a future feature 

Screenshots 
A log when screenshots where taken 

SessionData 
Calculated session data 

WindowData 
A record of the current active window captured periodically 

WindowsEvents 
A log of high risk windows events that occurred during a session 

End to end example 

Given a user: beplucke 
And a time range: (datetime(2021-03-20) .. datetime(2021-03-30)) 

Find the RecordId for the session 

Azure data explorer 

ConnectionEvents 
| where UserName == "beplucke" 
| where Timestamp between (datetime(2021-03-20) .. datetime(2021-03-30)) 

Take note of the values in the RecordId column 

Azure storage explorer or via the azure portal 

Connect/Navigate to AG_SovEng_ESM_FF -> storage account "storageesmff" -> blob container "testimages" -> folder RecordId noted earlier 

Screenshots of the session are contained in said folder 

 