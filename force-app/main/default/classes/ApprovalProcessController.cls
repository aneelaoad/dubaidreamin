/**
 * 
 * @author Faraz
 * @since March 2024
 */
public class ApprovalProcessController {
    @AuraEnabled(cacheable=true)
    public static List<DenormalizedSession> getSessionTime(String recordId){

        // System.debug(recordId);
        // System.debug(startTime);
        // System.debug(endTime);

        ApprovalProcessSelector approvalProcessInstance = new ApprovalProcessSelector();
       
       
       
        List<ProcessInstanceWorkitem>  selectedProcessInstanceWorkItem =  approvalProcessInstance.getProcessInstanceWorkItemById(recordId);
       // String processInstanceId = [SELECT ProcessInstanceId, Id FROM ProcessInstanceWorkitem WHERE Id =:recordId].ProcessInstanceId;
      
        List<ProcessInstance> selectedProcessInstance =  approvalProcessInstance.getProcessInstanceById(selectedProcessInstanceWorkItem[0].ProcessInstanceId);
       
        // String speakerId = [SELECT Id, TargetObjectId  FROM ProcessInstance WHERE Id =: processInstanceId].TargetObjectId;
      
          
    SessionSelector sessionSelectorInstance = new SessionSelector();
    List<Session__c> selectedSessions =  sessionSelectorInstance.getSessionById(selectedProcessInstance[0].TargetObjectId);
  //    Session__c currentSession  = [SELECT Id, Session_Start_Time__c, Session_End_Time__c From Session__c WHERE Id=:sessionId];



       SessionSpeakerSelector sessionSpeakerSelectorInstance = new SessionSpeakerSelector();
       List<Speaker__c> selectedSessionSpeaker =  sessionSpeakerSelectorInstance.getSpeakersBySessionId(selectedSessions[0].Id);
  System.debug('speaker size'+selectedSessionSpeaker.size());
  System.debug('speaker '+selectedSessionSpeaker);
       // String sessionId = [SELECT Id, Speaker__c, Session__c FROM Session_Speaker__c Where Speaker__c = : speakerId]. Session__c; 
       
  //  List<DenormalizedSpeaker> denormalizedSpeakerList = new List<DenormalizedSpeaker>();
   

     
    
    
    

      
    //    System.debug(selectedSessions[0].Session_Start_Time__c);
    //    System.debug(selectedSessions[0].Session_End_Time__c);

    List<DenormalizedSession> sessionItemsList = new List<DenormalizedSession>();

     

    
    DenormalizedSession denormalizedSession = new DenormalizedSession();
       denormalizedSession.setSessionName(selectedSessions[0].Name); 
       denormalizedSession.setSessionDescription(selectedSessions[0].Session_Description__c); 
       denormalizedSession.setSessionTrack(selectedSessions[0].Session_Track__c); 
       denormalizedSession.setSessionTitle(selectedSessions[0].Session_Title__c); 
       denormalizedSession.setStartTime(String.valueof(selectedSessions[0].Session_Start_Time__c));
       denormalizedSession.setEndTime(String.valueof(selectedSessions[0].Session_End_Time__c));
     
     
     
     
       for(Speaker__c selectedSpeaker:selectedSessionSpeaker){
        if(selectedSpeaker.Speaker_Type__c=='Primary Speaker'){
          denormalizedSession.setSpeakerName(selectedSpeaker.Speaker_Name__c); 
          denormalizedSession.setSpeakerSocialMedia(selectedSpeaker.Speaker_Social_Media__c); 
          denormalizedSession.setSpeakerPhone(selectedSpeaker.Phone_Number__c); 
          denormalizedSession.setSpeakerTarget(selectedSpeaker.Speaker_Target__c);
          denormalizedSession.setSpeakerRole(selectedSpeaker.Speaker_Role__c); 
          denormalizedSession.setSpeakerEmail(selectedSpeaker.Email__c); 
          denormalizedSession.setSpeakerCompanyName(selectedSpeaker.Company_Name__c); 
          denormalizedSession.setSpeakerInformation(selectedSpeaker.Speaker_Information__c); 
   

        }
        if(selectedSpeaker.Speaker_Type__c=='Co-Speaker'){
          denormalizedSession.setCoSpeakerName(selectedSpeaker.Speaker_Name__c); 
         // denormalizedSession.setSpeakerSocialMedia(selectedSpeaker.Speaker_Social_Media__c); 
          denormalizedSession.setCoSpeakerPhone(selectedSpeaker.Phone_Number__c); 
          denormalizedSession.setCoSpeakerRole(selectedSpeaker.Speaker_Role__c); 
          denormalizedSession.setCoSpeakerEmail(selectedSpeaker.Email__c); 
          denormalizedSession.setCoSpeakerCompanyName(selectedSpeaker.Company_Name__c); 
       //   denormalizedSession.setSpeakerInformation(selectedSpeaker.Speaker_Information__c);

        }


       }
     
     
     
     
     
     
     
       sessionItemsList.add(denormalizedSession);
      System.debug(sessionItemsList);
       return sessionItemsList;
    }


    @AuraEnabled
    public static void setSessionTime(String sessionName, String sessionStartTime, String sessionEndTime){
      // System.debug(sessionName);
      // System.debug(sessionStartTime);
      // System.debug(sessionEndTime);

      // try{
        System.debug(sessionStartTime);
        System.debug(sessionEndTime);
        Time startTime = Time.newInstance(Integer.valueOf(sessionStartTime.split(':')[0]), Integer.valueOf(sessionStartTime.split(':')[1]), 0 ,0);
        Time endTime  = Time.newInstance(Integer.valueOf(sessionEndTime.split(':')[0]), Integer.valueOf(sessionEndTime.split(':')[1]), 0 ,0);
        System.debug(startTime);
        System.debug(endTime);

        Date myDate = Date.newInstance(2024, 12, 9);
        Datetime startDateTime = Datetime.newInstance(myDate.year(), myDate.month(), myDate.day(), startTime.hour(), startTime.minute(), startTime.second());
        Datetime endDateTime = Datetime.newInstance(myDate.year(), myDate.month(), myDate.day(), endTime.hour(), endTime.minute(), endTime.second());
        // DateTime startDateTime = DateTime.newInstance(Date.today(), startTime);
        // DateTime endDateTime = datetime.newinstance(Date.today(), endTime);
        System.debug(startDateTime);
        System.debug(endDateTime);

        Long timeAvailable = endDateTime.getTime() - startDateTime.getTime();
        timeAvailable /= 60000;
        System.debug(timeAvailable);
        if(timeAvailable<30 && timeAvailable>60){
          throw new CustomException('Time Difference must be 30-60 minutes');
        }

      SessionSelector selectedSessionByName = new SessionSelector();

      List<Session__c> sessionList = selectedSessionByName.getSessionByName(sessionName);
      sessionList[0].Session_Start_Time__c= Time.newInstance(Integer.valueOf(sessionStartTime.split(':')[0]), Integer.valueOf(sessionStartTime.split(':')[1]), 0 ,0);
      sessionList[0].Session_End_Time__c= Time.newInstance(Integer.valueOf(sessionEndTime.split(':')[0]), Integer.valueOf(sessionEndTime.split(':')[1]), 0 ,0);
      // sessionList.add();
    System.debug(sessionList);
    Database.update(sessionList, true);
      // update sessionList;
    //  sessionList.add(new Session__c(Id=recordId, SessionStart));
      // }
      // catch(Exception e){

      //   throw new CustomException(e.getmessage());
      // }


    }

public class CustomException extends Exception {}

}