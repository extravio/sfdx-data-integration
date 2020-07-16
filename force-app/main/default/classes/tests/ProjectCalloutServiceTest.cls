@isTest
private class ProjectCalloutServiceTest {
    
    @isTest static void testQueuedJob() {
        
        Test.setMock(HttpCalloutMock.class, new ProjectCalloutServiceMock());

        Test.startTest();

        // Insert new opportunity - that will trigger the process builder
        Opportunity opp = TestDataFactory.createOpportunity('Closed Won');

        // Verify that a new Apex Job has been added to the queue.
        Integer ct = [SELECT COUNT() FROM AsyncApexJob];
        System.assertEquals(1, ct);

        AsyncApexJob jobInfo = [SELECT Id, Status,NumberOfErrors FROM AsyncApexJob][0];
        System.assertEquals('Queued', jobInfo.Status);

        // Stopping the test will run the job synchronously
        Test.stopTest();

        // Check the job has completed
        AsyncApexJob jobInfoCompleted = [SELECT Id, Status,NumberOfErrors FROM AsyncApexJob WHERE Id=:jobInfo.Id];
        System.assertEquals('Completed', jobInfoCompleted.Status);

        // Check the opportunity has been updated 
        Opportunity updatedOpp = [SELECT Id, StageName FROM Opportunity WHERE Id=:opp.Id];
        System.assertEquals('Submitted Project', updatedOpp.StageName);

    }

    @isTest static void testQueuedJobNegative() {
        
        Test.setMock(HttpCalloutMock.class, new ProjectCalloutServiceMockFailure());

        Test.startTest();

        // Insert new opportunity - that will trigger the process builder
        Opportunity opp = TestDataFactory.createOpportunity('Closed Won');

        // Verify that a new Apex Job has been added to the queue.
        Integer ct = [SELECT COUNT() FROM AsyncApexJob];
        System.assertEquals(1, ct);

        AsyncApexJob jobInfo = [SELECT Id, Status,NumberOfErrors FROM AsyncApexJob][0];
        System.assertEquals('Queued', jobInfo.Status);

        // Stopping the test will run the job synchronously
        Test.stopTest();

        // Check the job has completed
        AsyncApexJob jobInfoCompleted = [SELECT Id, Status,NumberOfErrors FROM AsyncApexJob WHERE Id=:jobInfo.Id];
        System.assertEquals('Completed', jobInfoCompleted.Status);

        // Check the opportunity has been updated 
        Opportunity updatedOpp = [SELECT Id, StageName FROM Opportunity WHERE Id=:opp.Id];
        System.assertEquals('Resubmit Project', updatedOpp.StageName);
        
    }


}