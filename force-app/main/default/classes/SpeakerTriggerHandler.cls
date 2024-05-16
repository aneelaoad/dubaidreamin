public with sharing class SpeakerTriggerHandler extends TriggerHandler {
    
    private List<Speaker__c> triggerNew;
    private Map<Id, Speaker__c> triggerOldMap;

    public override void beforeUpdate(){
        triggerOldMap = (Map<Id, Speaker__c>)Trigger.oldMap;
        triggerNew = (List<Speaker__c>)Trigger.new;

        Set<String> speakerNames = new Set<String>();
        Set<String> speakerEmails = new Set<String>();

        for (Speaker__c newSpeaker : triggerNew) {
            Speaker__c oldSpeaker = triggerOldMap.get(newSpeaker.Id);
            if (newSpeaker.Approval_Status__c == 'Approved' && oldSpeaker.Approval_Status__c != 'Approved') {
                speakerNames.add(newSpeaker.Speaker_Name__c);
                speakerEmails.add(newSpeaker.Email__c);
            }
        }

        if (!speakerNames.isEmpty() && !speakerEmails.isEmpty()) {
            Map<String, Id> attendeeMap = AttendeeSelector.getAttendeesbyNameandEmail(speakerNames, speakerEmails);

            Set<Id> attendeeIds = new Set<Id>(attendeeMap.values());
            Map<Id, Decimal> ticketAmountMap = TicketSelector.getTicketAmounts(attendeeIds);

            for (Speaker__c speaker : triggerNew) {
                String attendeeKey = speaker.Speaker_Name__c + '|' + speaker.Email__c;
                if (attendeeMap.containsKey(attendeeKey) && attendeeIds.contains(attendeeMap.get(attendeeKey))) {
                    speaker.Attendee__c = attendeeMap.get(attendeeKey);
                    System.debug('speaker attendee ' +speaker.Attendee__c );
                    speaker.Ticket_Amount__c = ticketAmountMap.get(attendeeMap.get(attendeeKey));
                    System.debug('speaker ticket amount ' +speaker.Ticket_Amount__c  );
                }
            }
        }
    }

    public SpeakerTriggerHandler() {
        this.triggerNew = (List<Speaker__c>)Trigger.new;
    }
}