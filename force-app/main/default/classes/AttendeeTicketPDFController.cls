public class AttendeeTicketPDFController {
    public static AttendeeTicket attendeeTicket { get; set; } // Change to static
    
    public class AttendeeTicket  {
        public String ticketNumber { get; set; }
        public Decimal amount { get; set; }
        public String attendeeName { get; set; }
        public String attendeeEmail { get; set; } 
        public String eventName { get; set; } 
        public String createdDate { get; set; } 
        public String createdTime { get; set; } 
        public String qrCode {get;set; }
    }
    
    public AttendeeTicketPDFController() {
        String ticketId = ApexPages.currentPage().getParameters().get('ticketId');
        setAttendeeInformation(ticketId);
    }
    
    public static void setAttendeeInformation(Id recordId) {
        System.debug('@@setAttendeeInformation'+recordId);
        attendeeTicket = new AttendeeTicket();
      
        Ticket__c ticketInfo = [SELECT Id, Name, Total_Amount__c, CreatedDate, Attendee__c, 
                                 Attendee__r.Dubai_Dreamin_QR_Code__c, Attendee__r.Attendee_Full_Name__c,
                                 Attendee__r.Email__c, Attendee__r.Event__r.Name 
                                 FROM Ticket__c WHERE Id =: recordId];
             
        attendeeTicket.attendeeName = ticketInfo.Attendee__r.Attendee_Full_Name__c; 
        attendeeTicket.attendeeEmail = ticketInfo.Attendee__r.Email__c;
        attendeeTicket.amount = ticketInfo.Total_Amount__c;
        attendeeTicket.ticketNumber = ticketInfo.Name;
        attendeeTicket.eventName = ticketInfo.Attendee__r.Event__r.Name;
        DateTime dateTimeIn = ticketInfo.CreatedDate;
        attendeeTicket.createdDate = String.valueOf(dateTimeIn.date());
        attendeeTicket.createdTime = String.valueOf(dateTimeIn.time());
        attendeeTicket.qrCode = ticketInfo.Attendee__r.Dubai_Dreamin_QR_Code__c;
    }
    
    @future(callout = true)
    public static void getAttendeeInfo(List<Id> recordIds) {
        List<ContentVersion> contentVersions = new List<ContentVersion>();
        

        Ticket__c primaryAttendeeTicket;

        String primaryAttendeeEmail;
        Id primaryAttendeeContactId;
        Id primaryAttendeeId;

        List<Ticket__c> primaryAttendeeTickets = [SELECT Primary_Attendee_Ticket__c, Attendee__r.Email__c, Attendee__r.Attendee__c 
                                                FROM Ticket__c 
                                                WHERE Id IN :recordIds 
                                                AND Attendee__r.isPrimaryAttendee__c = true];

        if (primaryAttendeeTickets.size() > 0) {
            primaryAttendeeTicket = primaryAttendeeTickets[0];
            
            primaryAttendeeEmail = primaryAttendeeTicket.Attendee__r.Email__c;
            primaryAttendeeContactId = primaryAttendeeTicket.Attendee__r.Attendee__c;
            primaryAttendeeId=primaryAttendeeTicket.Attendee__c;
            
        }


        

        // for (Id recordId : recordIds) {
        //     try {
        //         primaryAttendeeEmail = primaryAttendeeTicket.Attendee__r.Email__c;
        //         primaryContactId = primaryAttendeeTicket.Attendee__r.Attendee__c;
        //         primaryAttendeeId=primaryAttendeeTicket.Attendee__c;
        //         break;
        //     } catch (Exception e) {
        //         System.debug('email error');
        //     }
        // }

        for (Id recordId : recordIds) {
            PageReference pg = new PageReference('/apex/TicketPage?ticketId=' + recordId);
            pg.setRedirect(false);
            Blob pageContent;
            if (Test.isRunningTest()) {
                pageContent = Blob.valueOf('UNIT.TEST');
            } else {
                pageContent = pg.getContent();
            }
            
            ContentVersion conVer = new ContentDocumentUtils().constructContentVersion(pageContent, 'Attendee_Ticket_' + recordId + '.pdf');
            contentVersions.add(conVer);
        }
        
        
        insert contentVersions;
            System.debug('primary email '+ primaryAttendeeEmail);
        OrgWideEmailAddress owa = [SELECT Id, DisplayName, Address FROM OrgWideEmailAddress LIMIT 1];
        EmailTemplate template = [SELECT Id, Subject, Body, DeveloperName FROM EmailTemplate WHERE DeveloperName = 'Send_Email_To_Approved_Attendee_1713770888415'];
        Messaging.SingleEmailMessage myEmail = new Messaging.SingleEmailMessage();
        myEmail.setTemplateId(template.Id);
        myEmail.setToAddresses(new List<String>{primaryAttendeeEmail});
        myEmail.setWhatId(primaryAttendeeId);
        myEmail.setOrgWideEmailAddressId(owa.Id); 
        myEmail.setSaveAsActivity(false);
        myEmail.setTargetObjectId(primaryAttendeeContactId);
        // myEmail.setSubject(template.Subject);
        // myEmail.setHtmlBody(template.Body);

        List<Messaging.EmailFileAttachment> emailAttachments = new List<Messaging.EmailFileAttachment>();
        for (ContentVersion cv : contentVersions) {
            Messaging.EmailFileAttachment emailFileAttachment = new Messaging.EmailFileAttachment();
            emailFileAttachment.setFileName(cv.Title);
            emailFileAttachment.setBody(cv.VersionData);
            emailAttachments.add(emailFileAttachment);
        }
        List<Id> contentIds = new List<Id>();
    for (ContentVersion cv : contentVersions) {
        contentIds.add(cv.Id);
    }
    myEmail.setEntityAttachments(contentIds);
        
        if (!Test.isRunningTest()) {
            Messaging.sendEmail(new Messaging.SingleEmailMessage[]{myEmail});  
            System.debug('Email sent');          
        }
    }
}