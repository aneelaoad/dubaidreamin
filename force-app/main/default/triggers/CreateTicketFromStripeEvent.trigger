trigger CreateTicketFromStripeEvent on stripeGC__Stripe_Event__c (after insert) {
    List<ticket__c> secondaryAttendeesTickets = new List<ticket__c>();
    List<Messaging.SingleEmailMessage> emailsToSend = new List<Messaging.SingleEmailMessage>();
    List<Id> insertedTicketIds = new List<Id>(); 

    for (stripeGC__Stripe_Event__c eventRecord : Trigger.new) {
        if (eventRecord.stripeGC__Request_Body__c != null  && eventRecord.stripeGC__Event_Name__c=='checkout.session.completed') {
            Map<String, Object> eventData = (Map<String, Object>) JSON.deserializeUntyped(eventRecord.stripeGC__Request_Body__c);
            
            if (eventData.containsKey('data')) {
                Map<String, Object> dataMap = (Map<String, Object>) eventData.get('data');
                
                if (dataMap.containsKey('object')) {
                    Map<String, Object> objectMap = (Map<String, Object>) dataMap.get('object');
                    
                    if (objectMap.containsKey('client_reference_id')) {
                        String clientReferenceId = (String) objectMap.get('client_reference_id');
                        Decimal amountTotal = (Decimal) objectMap.get('amount_total');
						
						Decimal decimalAmountTotal = amountTotal.divide(100, 2);

                        List<Attendee__c> secondaryAttendees = [SELECT Id 
                                                                  FROM Attendee__c 
                                                                  WHERE Primary_Attendee__c = :clientReferenceId];
                        
                      
                        Integer totalAttendees = secondaryAttendees.size() + 1; 

                        ticket__c primaryTicket = new ticket__c();
                        primaryTicket.Attendee__c = clientReferenceId;
                        primaryTicket.TransactionID__c = eventRecord.Id;
                        primaryTicket.Total_Amount__c = decimalAmountTotal/totalAttendees;
                        
                        insert primaryTicket;
                        insertedTicketIds.add(primaryTicket.Id);


                        
                       
                        for (Attendee__c secondaryAttendee : secondaryAttendees) {
                            ticket__c secondaryTicket = new ticket__c();
                            secondaryTicket.Attendee__c = secondaryAttendee.Id;
                            secondaryTicket.TransactionID__c = eventRecord.Id;
                            secondaryTicket.Total_Amount__c = decimalAmountTotal/totalAttendees;
                          
                            secondaryTicket.Primary_Attendee_Ticket__c = primaryTicket.Id;
                            secondaryAttendeesTickets.add(secondaryTicket);
                            
                        }
                    }
                }
            }
        }
    }
    
    if (!secondaryAttendeesTickets.isEmpty()) {
        insert secondaryAttendeesTickets;
        for (ticket__c secondaryTicket : secondaryAttendeesTickets) {
            insertedTicketIds.add(secondaryTicket.Id);
        }
        
    }

    AttendeeTicketPDFController.getAttendeeInfo(insertedTicketIds);

}