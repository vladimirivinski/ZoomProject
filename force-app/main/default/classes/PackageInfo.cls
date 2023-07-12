@RestResource(urlMapping='/PackageInfo')
global class PackageInfo {
  global class Payload {
    public String organizationName;
    public String packageVersion;

    public Payload() {
      Organization myOrg = [Select o.Name From Organization o];
      this.organizationName = myOrg.Name;
      this.packageVersion = '1.11';
    }
  }

  @HttpGet
  global static Payload getInfo() {
    Payload payload = new Payload();
    return payload;
  }
}