public with sharing class MassDeleteExtension {
    private ApexPages.StandardSetController ssc;
    

    public MassDeleteExtension(ApexPages.StandardSetController controller) {
        this.ssc = controller;
    }

    public PageReference deleteSelected() {
        List<SObject> selected = (List<SObject>) ssc.getSelected();
        if (selected != null && !selected.isEmpty()) {
            
            system.debug('delete list :'+selected);
            delete selected;
           // ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, selected.size() + ' records deleted.'));
           //  String objName = ssc.getRecord().getSObjectType().getDescribe().getName();
        PageReference pageRef = new PageReference('/lightning/o/Enquiry__c/list?filterName=All_My_Open_Enquiries');
        pageRef.setRedirect(true);
        return pageRef;
        }
        return null;
    }
}