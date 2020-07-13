public with sharing class ProjectCalloutService implements Queueable { 

    private Opportunity opp;

    public ProjectCalloutService(Opportunity opp) {
        this.opp = opp;
        // System.Debug(this.opp);
    }

    // The PostOpportunityToPMS method is InvocableMethod sop it can be executed from Process Builder
    // The InvocableMethod must be static, so we're calling the constructor explicitly
    @InvocableMethod(label='Post Opportunity To PMS')
    public static void PostOpportunityToPMS(List<Opportunity> opps) {
        ProjectCalloutService pcs = new ProjectCalloutService(opps[0]);
        ID jobID = System.enqueueJob(pcs);
        // System.Debug('the job ID is: ' + jobID);
    }

    public void execute(QueueableContext context) {
        System.Debug('Opportunity Id: ' + this.opp.Id);
        ProjectCalloutService.QueueablePMSCall(this.opp.Id);
    }

    // future method has to be static and doesn't accept Objects as parameters
    @future(callout=true)
    public static void QueueablePMSCall(Id oppId) {

        Opportunity opp = [SELECT Id, Name, StageName, Type, AccountId, closeDate, Amount
                   FROM Opportunity
                   WHERE Id= :oppId
                  ][0];

        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('https://sb-integration-pms.herokuapp.com/projects');
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json;charset=UTF-8');
        request.setHeader('token', ProjectCalloutService.getToken());
        // Set the body as a JSON object
        request.setBody('{"name":"mighty moose"}');
        String body = 
            '{ "opportunityId": "' + opp.Id  + '", ' + 
            '  "opportunityName": "' + opp.Name  + '", ' + 
            '  "accountName": "' + opp.AccountId + '", ' + 
            '  "closeDate": "' + opp.closeDate  + '", ' + 
            '  "amount": "' + opp.Amount + '}';
        request.setBody(body);
        HttpResponse response = http.send(request);
        // If the request is successful, update stage name
        if (response.getStatusCode() == 200) {
            opp.StageName = 'Submitted Project	';
        } else {
            opp.StageName = 'Resubmit Project	';
        }
        update opp;
    }

    public static String getToken() {
        Map<String, ServiceTokens__c> ServiceToken = ServiceTokens__c.getAll();
        return ServiceToken.get('ProjectServiceToken').Token__c;
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