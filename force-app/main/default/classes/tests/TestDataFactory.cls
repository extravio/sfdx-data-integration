@isTest
public with sharing class TestDataFactory {
    public static Opportunity createOpportunity() {
        Opportunity opp = new Opportunity(
          Name = 'Test Project',
          CloseDate = Date.newInstance(2020, 7, 31),
          Type = 'New Project',
          StageName = 'Closed Won'
        );
        insert opp;
        return opp;
    }
}