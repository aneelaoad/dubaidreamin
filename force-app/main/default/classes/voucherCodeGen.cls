public class voucherCodeGen {
    
    
    public static void speakersVC(String SpeakerId){
        List<Speaker__c>lstSpeaker=[select id,Name,Speaker_name__c,Approval_Status__c,Voucher_code__c from Speaker__c where id=:SpeakerId];
        system.debug(lstSpeaker);
        
        For(Speaker__c speaker:lstSpeaker){
            
            if(speaker.Approval_Status__c =='Approved'){
                speaker.Voucher_Code__c=voucherCodeGeneration();
            }
            //update lstSpeaker
        }
    }
    
    
    public static String voucherCodeGeneration(){
        final String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
        String randomStr='';
        while (randomStr.length() < 10) {
        Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
        randomStr += chars.substring(idx, idx+1);                        
        } 
                            system.debug(randomStr);

        return randomStr;

    }
    
   public static Blob generateAES256Key() {
    Blob key = Crypto.generateAesKey(256);
    return key;
}
    
    public static void voucherGenEncrypt(String speakerId){

		list<Speaker__c>speakerList=[select id,name,Approval_Status__c,Voucher_Code__c from Speaker__c WHERE id=:speakerId AND Approval_Status__c='Approved'];
        Discount_Percentage__mdt discountPercent=[select Label,Percentage__c,Status__c from Discount_Percentage__mdt limit 1];
        Map<String, String> obj = new Map<String, String>();
        obj.put('speakerId',speakerList[0].id);
        obj.put('Approval Status',speakerList[0].Approval_Status__c);
        obj.put('Voucher Code',speakerList[0].Voucher_Code__c);
        obj.put('Percentage',String.valueOf(discountPercent.Percentage__c));
        String jsonText = JSON.Serialize(obj);
        system.debug('checking Json: '+jsonText);
        
        Blob aesKey = generateAES256Key();
        Blob blobData = Blob.valueOf(jsonText); 
        Blob encrypted = Crypto.encryptWithManagedIV('AES256', aesKey, blobData);
        String outletCode = EncodingUtil.base64Encode(encrypted);
        System.debug('**Voucher Code Encryption : '+outletCode);
        
        /*Blob decryptBlob = EncodingUtil.base64Decode(outletCode);
        Blob decrypted = Crypto.decryptWithManagedIV('AES256', aesKey, decryptBlob);
        String outletAccNum = decrypted.toString();
        System.debug('** Decrypted Outlet: '+outletAccNum);*/
    }    
    
      
  
}