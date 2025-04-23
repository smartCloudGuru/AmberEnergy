/**
 * Created by ukaya01 on 2/25/2021.
 */

public with sharing class IssueNotesImportController {

    public class IssueNote{
        @AuraEnabled
        public Integer index;
        @AuraEnabled
        public string meterRef;
        @AuraEnabled
        public string title;
        @AuraEnabled
        public string note;
        public Issue__c issue;
        @AuraEnabled
        public string status;
    }

    static Map<Integer,IssueNote> issueNoteMap;
    static Map<String, List<Issue__c>> issuesByMeter;
    static Map<Integer,ContentNote> contentNoteByIndex;
    static Map<Integer,ContentDocumentLink> documentLinkByIndex;
    static Map<Integer,String> createdDocuments;

    @AuraEnabled
    public static List<IssueNote> convertCSV(string base64){
        transformCSV(base64);
        return issueNoteMap.values();
    }

    @AuraEnabled
    public static List<IssueNote> processRecords(string notes){
        List<IssueNote> issueNotes = (List<IssueNote>)JSON.deserialize(notes, List<IssueNote>.class);
        issueNoteMap = new Map<Integer,IssueNote>();
        for(IssueNote issueNote : issueNotes){
            issueNoteMap.put(issueNote.index,issueNote);
        }
        fetchIssuesByMeter();
        prepareContentNotes();
        prepareContentDocumentLinks();
        updateNoteStatus();
        return issueNoteMap.values();
    }

    //Transform CSV content into IssueNote wrapper
    static void transformCSV(string base64){

        issueNoteMap = new Map<Integer,IssueNote>();
        String jsonString = JSON.deserializeUntyped(base64).toString();
        List<String> csvRows = jsonString.split('\n');

        for(Integer i = 1; i < csvRows.size(); i++){

            String csvRow = csvRows[i];
            Integer startIndex;
            Integer endIndex;

            while(csvRow.indexOf('"') > -1){
                if(startIndex == null){
                    startIndex = csvRow.indexOf('"');
                    csvRow = csvRow.substring(0, startIndex) + ':quotes:' + csvRow.substring(startIndex+1, csvRow.length());
                }else{
                    if(endIndex == null){
                        endIndex = csvRow.indexOf('"');
                        csvRow = csvRow.substring(0, endIndex) + ':quotes:' + csvRow.substring(endIndex+1, csvRow.length());
                    }
                }

                if(startIndex != null && endIndex != null){
                    String sub = csvRow.substring(startIndex, endIndex);
                    sub = sub.replaceAll(',', ':comma:');
                    csvRow = csvRow.substring(0, startIndex) + sub + csvRow.substring(endIndex, csvRow.length());
                    startIndex = null;
                    endIndex = null;
                }
            }

            List<String> csvRowData = new List<String>();
            for(String column : csvRow.split(',')){
                column = column.replaceAll(':quotes:', '').replaceAll(':comma:', ',');
                csvRowData.add(column);
            }

            if(String.isNotBlank(csvRowData[0]) && String.isNotBlank(csvRowData[1]) && String.isNotBlank(csvRowData[2])){
                IssueNote issueNote = new IssueNote();
                IssueNote.index = i;
                issueNote.meterRef = csvRowData[0];
                issueNote.title = csvRowData[1];
                issueNote.note = csvRowData[2];
                issueNote.status = '';
                issueNoteMap.put(issueNote.index,issueNote);
            }

        }

    }

    //Fetch Issues for related meters
    static void fetchIssuesByMeter(){
        issuesByMeter = new Map<String,List<Issue__c>>();
        Set<String> meterRefs = new Set<String>();

        for(IssueNote issueNote : issueNoteMap.values()){
            meterRefs.add(issueNote.meterRef);
        }

        //get the issues based on the meter refs
        for(Issue__c issue : [SELECT Id, Meter__r.Name, CreatedDate
                                FROM Issue__c
                               WHERE Meter__r.Name IN :meterRefs AND Status__c != 'Complete'
                            ORDER BY Meter__r.Name ASC, CreatedDate DESC]){

            if(issuesByMeter.containsKey(issue.Meter__r.Name)){
                issuesByMeter.get(issue.Meter__r.Name).add(issue);
            }else{
                issuesByMeter.put(issue.Meter__r.Name,new List<Issue__c>{issue});
            }
        }

    }

    //Prepare Content Notes to insert for each meter
    static void prepareContentNotes(){
        contentNoteByIndex = new Map<Integer,ContentNote>();
        for(IssueNote issueNote : issueNoteMap.values()){
            if(issuesByMeter.containsKey(issueNote.meterRef)){
                if(issuesByMeter.get(issueNote.meterRef).size() > 1){
                    issueNote.status = 'More than one issue found the given meter reference';
                }else{
                    issueNote.issue = issuesByMeter.get(issueNote.meterRef)[0];

                    ContentNote note = new ContentNote();
                    note.Title = issueNote.title;
                    note.Content = Blob.valueOf(issueNote.note);
                    contentNoteByIndex.put(issueNote.index,note);
                }
            }else{
                issueNote.status = 'No Open Issue found for the given meter reference';
            }
        }

    }

    //Insert Content Notes & Content Document Links
    static void prepareContentDocumentLinks(){
        createdDocuments = new Map<Integer,String>();
        documentLinkByIndex = new Map<Integer,ContentDocumentLink>();
        if(!contentNoteByIndex.isEmpty()){
            Database.insert(contentNoteByIndex.values(), false);
            for (Integer index : contentNoteByIndex.keySet()) {
                ContentNote note = contentNoteByIndex.get(index);
                IssueNote issueNote = issueNoteMap.get(index);
                if(note.Id != null){
                    ContentDocumentLink cdl = new ContentDocumentLink();
                    cdl.ContentDocumentId   = note.Id;
                    cdl.LinkedEntityId      = issueNote.issue.Id;
                    cdl.Visibility          = 'InternalUsers';
                    cdl.ShareType           = 'I';
                    documentLinkByIndex.put(index,cdl);
                }else{
                    //handle errors
                    createdDocuments.put(index,'Error Creating ContentNote');
                }
            }

            if(!documentLinkByIndex.isEmpty()){
                Database.insert(documentLinkByIndex.values(), false);
                for (Integer index : documentLinkByIndex.keySet()) {
                    ContentDocumentLink docLink = documentLinkByIndex.get(index);
                    if(docLink.Id == null){
                        createdDocuments.put(index,'Error Creating ContentDocumentLink');
                    }else{
                        createdDocuments.put(index,'Success');
                    }
                }
            }
        }
    }

    //Update Note status from created documents
    static void updateNoteStatus(){
        for(IssueNote issueNote : issueNoteMap.values()){
            if(issueNote.issue != null && createdDocuments.containsKey(issueNote.index)){
                issueNote.status = createdDocuments.get(issueNote.index);
            }
        }
    }

}