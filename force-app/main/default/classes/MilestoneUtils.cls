public class MilestoneUtils {
    public static void completeMilestone(List<Id> caseIds, 
            String milestoneName, DateTime complDate) {  
    List<CaseMilestone> cmsToUpdate = [select Id, completionDate
            from CaseMilestone cm
            where caseId in :caseIds and cm.MilestoneType.Name=:milestoneName 
            and completionDate = null limit 1];
    if (cmsToUpdate.isEmpty() == false){
        for (CaseMilestone cm : cmsToUpdate){
            cm.completionDate = complDate;
            }
        update cmsToUpdate;
        }
    }
}