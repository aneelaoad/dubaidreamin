/**
* @author: Muhammad Raza
* @description: This Class for  selecting session speakers
* @since: 01/01/24
* @Last Modified by:  Muhammad Raza
*/
public with sharing class SessionSpeakerSelector {
    
/**
* 
* @param whereClause - An optional WHERE clause to filter session speakers.
* @return List<Session_Speaker__c> - A list of session speakers that meet the specified criteria.
* @description: This method constructs a dynamic SOQL query to fetch session speakers with specified fields.
*                 WHERE clause is optional and can be used for additional filtering.
*/
    
    public  List<Session_Speaker__c> getSessionSpeakersList(String whereClause){
        String clause =  String.IsEmpty(whereClause)?'':'WHERE '+whereClause;
        String queryOnSessionSpeaker = 'SELECT Speaker__r.Id,Speaker__r.Approval_Status__c, Speaker__r.Speaker_Name__c, Speaker__r.Speaker_Title__c, Speaker__r.Email__c, Speaker__r.Phone_Number__c, Speaker__r.Speaker_Information__c, Speaker__r.Speaker_Profile_Image__c, Speaker__r.Speaker_Role__c, Speaker__r.Company_Name__c, Speaker__r.Speaker_Social_Media__c, Speaker__r.Speaker_Target__c, Speaker__r.Speaker_Type__c, Session__c ' +
            'FROM Session_Speaker__c '
            + clause  ;
        List<Session_Speaker__c> sessionSpeakers = Database.query(queryOnSessionSpeaker);
        return   sessionSpeakers;
    }
    
/**
* 
* @param sessionId - The ID of the session to filter session speakers.
* @return List<Speaker__c> - A list of speakers associated with the specified session.
* @description: Retrieves a list of speakers associated with a specific session ID.
*/
    
    public  List<Speaker__c> getSpeakersBySessionId(String sessionId){
        String clause = 'Session__c  = \''+sessionId+'\' ';
        List<Session_Speaker__c> sessionSpeakers = getSessionSpeakersList(clause);
        
        List<Speaker__c> lstOfSpeakers = new List<Speaker__c>();
        
        for (Session_Speaker__c sessionSpeaker : sessionSpeakers) {
            Speaker__c speaker = sessionSpeaker.Speaker__r;
            if (speaker != null) {
                lstOfSpeakers.add(speaker);
            }
        }
        return lstOfSpeakers; 
    } 




    /**
     * @description gets session Session Speaker by speaker id (Speaker__c)
     * @param speakerId 
     * @return  `List<Session_Speaker__c>`
     */
    public  List<Session_Speaker__c> getSessionSpeakerBySpeakerId(String speakerId){
        String clause = 'Speaker__c  = \''+speakerId+'\' ';
        List<Session_Speaker__c> sessionSpeakers = getSessionSpeakersList(clause);
        
        if (sessionSpeakers.size() > 0) {
            return sessionSpeakers;
        }
        return sessionSpeakers; 
    } 

    // @AuraEnabled (cacheable=true)
    // public static List<Session__c> searchSessionsByRole( String searchKey){
    //     String searchVal = '%' + searchKey + '%';
    //     List<Session_Speaker__c> lstOfSessions=[Select Id,Speaker__r.Speaker_Name__c,Session__r.Id From Session_Speaker__c Where Speaker__r.Speaker_Role__c LIKE: searchVal  ]; 
        
       
        
    // }
    @AuraEnabled(cacheable=true)
    public static List<Session__c> searchSessionsByRole(String searchKey) {
    String searchVal = '%' + searchKey + '%';
    
    
    List<Id> sessionIds = new List<Id>();
    List<Session_Speaker__c> sessionSpeakers = [SELECT Session__r.Id 
                                                 FROM Session_Speaker__c 
                                                 WHERE Speaker__r.Speaker_Role__c LIKE :searchVal];

    for (Session_Speaker__c sessionSpeaker : sessionSpeakers) {
        sessionIds.add(sessionSpeaker.Session__r.Id);
    }

    
    List<Session__c> sessions = new List<Session__c>();
    if (!sessionIds.isEmpty()) {
        sessions = [SELECT Id, Session_Title__c,Speaker_Name__c
                    FROM Session__c 
                    WHERE Id IN :sessionIds];
    }
    System.debug('sessions'+sessions);
    return sessions;
}

    
}