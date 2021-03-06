// to get 100% code coverage in BillingCalloutServiceTest
public with sharing class CredentialHelper {
    public static String getSoapUsername() {
        ServiceCredentials__c ServiceCredentials = ServiceCredentials__c.getInstance('BillingServiceCredential');
        if (ServiceCredentials != null) {
            return ServiceCredentials.Username__c;
        }
        return '';
    }
    public static String getSoapPassword() {
        ServiceCredentials__c ServiceCredentials = ServiceCredentials__c.getInstance('BillingServiceCredential');
        if (ServiceCredentials != null) {
            return ServiceCredentials.Password__c;
        }
        return '';
    }
}
