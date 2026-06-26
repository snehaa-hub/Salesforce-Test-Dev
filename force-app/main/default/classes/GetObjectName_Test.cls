@istest
public class GetObjectName_Test {
	@isTest
    static void reqTestMethod(){
        Project__c project = new Project__c();
        project.Name = 'TestProject';
        project.Project_Area__c = 10000; 
        project.Project_Area_UOM__c = 'Sq.Meter';
        insert project;
	
        GetObjectName.Request req = new GetObjectName.Request();
        req.recordId = project.Id;
        Test.startTest();
        GetObjectName.getObject(project.Id);
        GetObjectName.execute(new List<GetObjectName.Request>{req});
        System.assertEquals('Project__c', GetObjectName.getObject(project.Id),'mesg');
        Test.stopTest();
    }
}