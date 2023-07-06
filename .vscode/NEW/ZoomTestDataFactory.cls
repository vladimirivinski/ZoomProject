@isTest
public with sharing class ZoomTestDataFactory {

    public static User createUser(String prof, String email){
        CallCenter cc =[SELECT Id FROM CallCenter LIMIT 1];
        Profile adminProfile = [SELECT Id FROM Profile WHERE Name = :prof LIMIT 1];
        User usr = new User();
        usr.Email = 'testuser' + email;
        usr.Username = 'testuser' + email;
        usr.FirstName = 'Test';
        usr.LastName = 'User';
        usr.Alias = 'tuser';
        usr.TimeZoneSidKey = 'America/Los_Angeles';
        usr.LocaleSidKey = 'en_US';
        usr.EmailEncodingKey = 'UTF-8';
        usr.LanguageLocaleKey = 'en_US';
        usr.isActive = true;
        usr.ProfileId = adminProfile.Id;
        usr.CallCenterId = cc.Id;
        insert usr;
        return usr;
    }

    public static List<User> createListUsers(Integer count, String prof, String email){
        CallCenter cc =[SELECT Id, name FROM CallCenter LIMIT 1];
        Profile adminProfile = [SELECT Id FROM Profile WHERE Name = :prof LIMIT 1];
        List<User> testUsers = new List<User>();
        for (Integer i = 0; i < count; i++) {
            User usr = new User();
            usr.Email = 'testuser' + i + email;
            usr.Username = 'testuser' + i + email;
            usr.FirstName = 'Test' + i;
            usr.LastName = 'User ' + i;
            usr.Alias = 'tuser' + i;
            usr.TimeZoneSidKey = 'America/Los_Angeles';
            usr.LocaleSidKey = 'en_US';
            usr.EmailEncodingKey = 'UTF-8';
            usr.LanguageLocaleKey = 'en_US';
            usr.isActive = true;
            usr.ProfileId = adminProfile.Id;
            usr.CallCenterId = cc.Id;
            testUsers.add(usr);
        }
        insert testUsers;
        return testUsers;
    }
}