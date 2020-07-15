public with sharing class ProjectCalloutService { 

    // The PostOpportunityToPMS method is InvocableMethod so it can be executed from Process Builder
    // The InvocableMethod must be static
    @InvocableMethod(label='Post Opportunity To PMS')
    public static void PostOpportunityToPMS(List<Id> oppIds) {
        ProjectCalloutService.QueueablePMSCall pms = new ProjectCalloutService.QueueablePMSCall(oppIds);
        ID jobID = System.enqueueJob(pms);
        System.Debug('the job ID is: ' + jobID);
    }
    
    // Inner QueueablePMSCall class
    // Implements Database.AllowsCallouts
    // https://www.forcetalks.com/salesforce-topic/what-is-database-allowscallouts-in-salesforce/
    public class QueueablePMSCall implements Queueable, Database.AllowsCallouts { 
        
        private Opportunity opp;
        private Id oppId;

        public QueueablePMSCall(List<Id> oppIds) {
            this.oppId = oppIds[0];
            this.opp = [SELECT Id, Name, StageName, Type, AccountId, closeDate, Amount
                        FROM Opportunity
                        WHERE Id= :this.oppId
                        ][0];
        }

        public void execute(QueueableContext context) {
            System.Debug('Execute: Opportunity Id: ' + this.opp.Id);
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint('https://sb-integration-pms.herokuapp.com/projects');
            request.setMethod('POST');
            request.setHeader('Content-Type', 'application/json;charset=UTF-8');
            request.setHeader('token', this.getToken());
            // Set the body as a JSON object
            request.setBody('{"name":"mighty moose"}');
            String body = 
                '{ "opportunityId": "' + this.opp.Id  + '", ' + 
                '  "opportunityName": "' + this.opp.Name  + '", ' + 
                '  "accountName": "' + this.opp.AccountId + '", ' + 
                '  "closeDate": "' + this.opp.closeDate  + '", ' + 
                '  "amount": "' + this.opp.Amount + '}';
            request.setBody(body);
            HttpResponse response = http.send(request);
            // If the request is successful, update stage name
            if (response.getStatusCode() == 200) {
                this.opp.StageName = 'Submitted Project	';
            } else {
                this.opp.StageName = 'Resubmit Project	';
            }
            update this.opp;
        }

        private String getToken() {
            Map<String, ServiceTokens__c> ServiceToken = ServiceTokens__c.getAll();
            return ServiceToken.get('ProjectServiceToken').Token__c;
        }
    }
}

/*
Test in console
---------------------
Opportunity opp = [SELECT Id, Name, StageName, Type 
                   FROM Opportunity
                   WHERE Id= '0062w000005sWnxAAE'
                  ];
opp.Type='New Project';
opp.StageName='Closed Won';
update opp;
*/