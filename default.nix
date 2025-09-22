final: prev:
{
  fetchSteam = prev.callPackage ./fetch-steam {};
  steamworks-sdk-redist = prev.callPackage ./steamworks-sdk-redist {};
}
