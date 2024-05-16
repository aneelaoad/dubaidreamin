/**
* @author: Muhammad Raza
* @description:  Controller Class for handling session information.
* @since: 01/01/24
* @Last Modified by: Muhammad Raza
*/
public with sharing class SessionController {
    
/**
* 
* @description:  This method utilizes the SessionSelector and SessionSpeakerSelector 
*                classes to fetch session and speaker information for the specified event.
* @param eventId - The ID of the event for which to retrieve session information.
* @return List<DenormalizedSession> - A list of denormalized session information for the specified event.
*/
    @AuraEnabled(cacheable=true)
    public static List<DenormalizedSession> getSessions(String eventId){
        List<Session__c> sessionList = new SessionSelector().getSessionsByEventId(eventId);
        List<DenormalizedSession> denormalizedSessionList = new List<DenormalizedSession>();
        
        for (Session__c session : sessionList) {
            DenormalizedSession denormalizedSession = new DenormalizedSession();
            denormalizedSession.sessionTitle = session.Session_Title__c;
            denormalizedSession.sessionDescription = session.Session_Description__c;
            denormalizedSession.sessionStartDate = session.Session_Start_Date__c;
            denormalizedSession.sessionEndDate = session.Session_End_Date__c;
            denormalizedSession.sessionDuration = session.Session_Duration__c;
            if (session.Session_Start_Time__c != null) {
                DateTime sessionStartTime = DateTime.newInstance(session.Session_Start_Date__c, session.Session_Start_Time__c);
                denormalizedSession.sessionStartTime = sessionStartTime.format('hh:mm a');
            } else {
                denormalizedSession.sessionStartTime = 'N/A';
            }

            if (session.Session_End_Time__c != null) {
                DateTime sessionEndTime = DateTime.newInstance(session.Session_End_Date__c, session.Session_End_Time__c);
                denormalizedSession.sessionEndTime = sessionEndTime.format('hh:mm a');
            } else {
                denormalizedSession.sessionEndTime = 'N/A';
            }

            
            // Get speakers for the current session
            List<Speaker__c> lstOfSpeakers = new SessionSpeakerSelector().getSpeakersBySessionId(session.Id);
            
            // Create a list of DenormalizedSpeaker objects
            List<DenormalizedSpeaker> denormalizedSpeakers = new List<DenormalizedSpeaker>();
            for (Speaker__c speaker : lstOfSpeakers) {
                DenormalizedSpeaker denormalizedSpeaker = new DenormalizedSpeaker();
                denormalizedSpeaker.speakerName = speaker.Speaker_Name__c;
                denormalizedSpeaker.speakerImage = speaker.Speaker_Profile_Image__c;
                denormalizedSpeakers.add(denormalizedSpeaker);
            }
            
            // Assign the list of speakers to the lstOfSpeakers property of DenormalizedSession
            denormalizedSession.lstOfSpeakers = denormalizedSpeakers;
            
            denormalizedSessionList.add(denormalizedSession);
        }
        
        return denormalizedSessionList;
    }
}