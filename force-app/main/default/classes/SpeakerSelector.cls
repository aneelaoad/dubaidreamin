/**
 *@author: Fatima
* @description: For retrieving Speaker records
* @since: 07/05/24
 */

public without sharing class SpeakerSelector {
    

/**
 * @description retrieving speaker record
 * @param whereClause 
 * @return  `List<Speaker__c>`
 */
    private static List<Speaker__c> getSpeaker(String whereClause) {
        String clause = whereClause != null ? ' WHERE ' + whereClause : '';
        String query = 'SELECT Id, Attendee__c, Ticket_Amount__c FROM Speaker__c ' + clause;
        return Database.query(query);
    }

    /**
     * @description Retrieving speaker by Id
     * @param Id 
     * @return  `Speaker__c`
     */
    public Speaker__c getSpeakerById(String Id) {

        String clause =  ' Id = \'' + Id + '\'';
        List<Speaker__c> speaker = getSpeaker(clause);
        if (speaker.size() > 0) {
             return speaker.get(0);
        }
        return null;
    
      
    }
}