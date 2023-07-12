Public class AutoConvertLeadsNoOpp
{
    @InvocableMethod
    public static void LeadAssign(List<Id> LeadIds)
    {
            Database.LeadConvert Leadconvert = new Database.LeadConvert();
        	Leadconvert.setDoNotCreateOpportunity(true);
            Leadconvert.setLeadId(LeadIds[0]);
            LeadStatus Leads= [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1];
            Leadconvert.setConvertedStatus(Leads.MasterLabel);
            Database.LeadConvertResult Leadconverts = Database.convertLead(Leadconvert);
            System.assert(Leadconverts.isSuccess());
   }
}