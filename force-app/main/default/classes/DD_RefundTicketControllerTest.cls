/**
 *@author: Fatima
* @description: Test class for dubai dreamin refund controller
* @since: 07/05/24
 */


 @isTest
 global class DD_RefundTicketControllerTest {
 
     @isTest
     global static void testProcessRefund() {
        
         Speaker__c speaker = new Speaker__c(
             Speaker_Name__c = 'Test Speaker',
             Email__c = 'test@example.com',
             Approval_Status__c = 'Pending'
         );
         insert speaker;
 
         Contact testContact = new Contact(
             FirstName = 'Test',
             LastName = 'Speaker',
             Email = 'test@example.com'
         );
         insert testContact;
 
         Attendee__c attendee = new Attendee__c(
             Attendee__c = testContact.Id,
             Email__c = 'test@example.com' 
         );
         insert attendee;
 
         Event__c testEvent = new Event__c(Event_Title__c = 'Dubai Dreamin');
         insert testEvent;
 
         stripeGC__Stripe_Event__c stripeEvent = new stripeGC__Stripe_Event__c(
             stripeGC__Stripe_Event_Id__c = 'Test Stripe Event',
             stripeGC__Event_Name__c= 'checkout.session.completed',
             stripeGC__Request_Body__c ='{"data":{"object":{"client_reference_id":"' + attendee.Id + '","amount_total":1800,"payment_intent":"pi_test123"}}}' 
         );
         insert stripeEvent;
 
         system.debug('stripe event record' + stripeEvent.Id);
 
    //      List<Ticket__c> tickets = [SELECT Id, Total_Amount__c, Attendee__c, TransactionId__c 
    //      FROM Ticket__c 
    //      WHERE TransactionId__c = :stripeEvent.Id];

    // System.assertNotEquals(0, tickets.size(), 'Ticket should be created for the Stripe Event.');
    // System.debug('Ticket ' +tickets);
 
         speaker.Approval_Status__c = 'Approved';
         update speaker;
         
         Test.startTest();
         Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
         
         List<DD_RefundTicketController.FlowInput> flowInputs = new List<DD_RefundTicketController.FlowInput>();
         DD_RefundTicketController.FlowInput input = new DD_RefundTicketController.FlowInput();
         input.recordId = speaker.Id;
         flowInputs.add(input);
         DD_RefundTicketController.processRefund(flowInputs);
 
         Test.stopTest();
        
         SpeakerSelector speakerSelector=new SpeakerSelector();
         Speaker__c updatedSpeaker = speakerSelector.getSpeakerById(speaker.Id);
         System.assertEquals(0, updatedSpeaker.Ticket_Amount__c, 'Ticket Amount should be updated to 0 after refund');
     }
 
     global class MockHttpResponseGenerator implements HttpCalloutMock {
         
         global HTTPResponse respond(HTTPRequest req) {
             
             HttpResponse res = new HttpResponse();
             res.setStatusCode(200);
             res.setBody('{"url":"https://mockrefunds.com"}');
             return res;
         }
     }
     
 }