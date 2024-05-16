/**
* @author: Aneela Oad
* @description: Manages the logic and functionality related to attendee registration.
* @since: 22/02/24
* @Last Modified by: Aneela Oad
*/
public without sharing class DubaiRSVPController {
    
 private static final string API_KEY = 'sk_test_51Ooi90BG9mkkVMIk0Y9ms1YRanZ5Ypw16g9NGPa2VsQbdjTyKFbGoIqg6bx9lqkZXV4qaJ4qkNCS4MiLA8FL4SrR00s9Dxvc6Y';
//   private static final string API_KEY = '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';
 private static final string END_POINT = 'https://api.stripe.com/v1/checkout/sessions';
    /**
    * @author: Aneela Oad
    * @description: Handles registration of attendee along with his/her payment
    * @param  String attendeeInfo
    * @return: void
    */
   @AuraEnabled

   public static  Id registerAttendees(String attendeesInfo) {
      
        List<DenormalizedAttendee> attendeesList = (List<DenormalizedAttendee>) JSON.deserialize(attendeesInfo, List<DenormalizedAttendee>.class);
       Id primaryAttendeeId;
   
       List<Attendee__c> attendeesToInsert = new List<Attendee__c>();
   
       for (DenormalizedAttendee denormalizedAttendeeInfo : attendeesList) {
           List<DenormalizedTicket> ticketsList = denormalizedAttendeeInfo.ticketsList;
   
           List<Contact> existingContacts = ContactSelector.getContactsByEmail(denormalizedAttendeeInfo.email);
           Contact existingContact;
           Id contactId;
   
           if (existingContacts.isEmpty()) {
               Contact contact = new Contact();
               contact.FirstName = denormalizedAttendeeInfo.firstName;
               contact.LastName = denormalizedAttendeeInfo.lastName;
               contact.Email = denormalizedAttendeeInfo.email;
               insert contact;
   
               contactId = contact.Id;
           } else {
               existingContact = existingContacts.get(0);
               contactId = existingContact.Id;
           }
   
           Attendee__c attendee = new Attendee__c(
               Event__c = denormalizedAttendeeInfo.eventId,
               Attendee__c = contactId,
               Company_Size__c = denormalizedAttendeeInfo.companySize,
               Food_Preference__c = denormalizedAttendeeInfo.foodPreference,
               Message__c = denormalizedAttendeeInfo.message,
               Phone__c = denormalizedAttendeeInfo.phone,
               Session_Interest__c = denormalizedAttendeeInfo.sessionInterest,
               Tshirt_Size__c = denormalizedAttendeeInfo.tShirtSize,
               Company_Name__c = denormalizedAttendeeInfo.designation,
               Trailblazer_Id__c = denormalizedAttendeeInfo.trailblazerId,
               Linkedin_Id__c = denormalizedAttendeeInfo.linkedinId,
               Email__c = denormalizedAttendeeInfo.email,
               Country__c = denormalizedAttendeeInfo.country
           );
           if (denormalizedAttendeeInfo.primary) {
               attendee.isPrimaryAttendee__c = true;
               
           }
           attendeesToInsert.add(attendee);
       }
   
       if (!attendeesToInsert.isEmpty()) {
           insert attendeesToInsert;
       }
        for (Attendee__c attendee : attendeesToInsert) {
           if (attendee.isPrimaryAttendee__c) {
               primaryAttendeeId = attendee.Id;
               break;
           }
       }
   
       // Assign primary attendee ID to all other attendees
       for (Attendee__c attendee : attendeesToInsert) {
           if (!attendee.isPrimaryAttendee__c) {
               attendee.Primary_Attendee__c = primaryAttendeeId;
           }
       }
    if (!attendeesToInsert.isEmpty()) {
           update attendeesToInsert;
       }
   
       System.debug('attendeesToInsert' +attendeesToInsert);
       return primaryAttendeeId;
       // return attendeesToInsert;
   }
   


public static Boolean attendeeExistsForEvent( String email, Id eventId) {
    Integer count = [SELECT COUNT() FROM Attendee__c WHERE Attendee__r.Email = :email AND Event__c = :eventId];
    return count > 0;
}

@AuraEnabled
  public static string createPaymentPage(String attendeeId, Integer quantity, String priceId, String redirectUrl, String couponId){
    String paymentLinkId;
    HttpRequest req = new HttpRequest();
    HttpResponse res = new HttpResponse();
    Http http = new Http();

    req.setEndPoint(END_POINT);
    req.setMethod('POST');
    req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
    String body = '&line_items[0][quantity]='+quantity + '&line_items[0][price]='+priceId+'&success_url='+redirectUrl+'&client_reference_id='+attendeeId+'&mode=payment';
    if (couponId != null) {
        body += '&discounts[0][coupon]=' + couponId;
    }
    req.setHeader('Authorization', 'Bearer ' + API_KEY);
    req.setBody(body);

     res =  http.send(req);
     System.debug('res.getBody(): ' +res.getBody());

      if (res.getStatusCode() == 200) {
              paymentLinkId =   getPaymentLinkId(res.getBody());
             System.debug('paymentLinkId: ' +paymentLinkId);
      }
 
        return paymentLinkId;
      
  }


 private static String getPaymentLinkId(String responseBody) {
     
        Map<String, Object> responseMap = (Map<String, Object>)JSON.deserializeUntyped(responseBody);
        String pageURL =  (String)responseMap.get('url');
        return pageURL;
    }


    @AuraEnabled(cacheable=true)
    public static DenormalizedPromotionCode fetchCouponId(String promoCode) {
        // Query the DD_Promotion_Code custom metadata object
        List<DD_Promotion_Codes__mdt> promoCodes = [SELECT Id, Coupon_Id__c, Promo_Code__c, Off__c, Activation_Date__c, Expiry_Date__c FROM DD_Promotion_Codes__mdt WHERE Promo_Code__c = :promoCode LIMIT 1];
         Date currentDate = Date.TODAY();
       
        if (!promoCodes.isEmpty()) {
            // return promoCodes[0];
            DD_Promotion_Codes__mdt promoCodeRecord = promoCodes[0];
            DenormalizedPromotionCode denormalizedRecord = new DenormalizedPromotionCode();

            // Instantiate the DenormalizedPromotionCode class and assign the attributes
    
            denormalizedRecord.couponId = promoCodeRecord.Coupon_Id__c;
            denormalizedRecord.promoCode = promoCodeRecord.Promo_Code__c;
            denormalizedRecord.activationDate = promoCodeRecord.Activation_Date__c;
            denormalizedRecord.expiryDate = promoCodeRecord.Expiry_Date__c;
            denormalizedRecord.discountPercentage = Integer.valueOf(promoCodeRecord.Off__c);
            denormalizedRecord.isActive = promoCodeRecord.Activation_Date__c <= currentDate && promoCodeRecord.Expiry_Date__c >= currentDate;

            System.debug(denormalizedRecord);
            System.debug(promoCodeRecord.Activation_Date__c == currentDate && promoCodeRecord.Expiry_Date__c > currentDate);
            return denormalizedRecord;    
        } else {
            // Throw an exception if promo code doesn't match any records
            throw new AuraHandledException('Promo code not found or invalid');
        }

        
    }


public class CustomException extends Exception {}

}