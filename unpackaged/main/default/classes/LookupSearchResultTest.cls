/**
 * Created by ukaya01 on 9/29/2021.
 */

@isTest
public with sharing class LookupSearchResultTest {

    @isTest
    static void compareToNullTitles() {
        LookupSearchResult r1 = getSearchResult(null);
        LookupSearchResult r2 = getSearchResult(null);

        Integer compareResult = r1.compareTo(r2);

        System.assertEquals(0, compareResult);
    }

    @isTest
    static void compareToNullTitle() {
        LookupSearchResult r1 = getSearchResult(null);
        LookupSearchResult r2 = getSearchResult('a');

        Integer compareResult = r1.compareTo(r2);

        System.assertEquals(1, compareResult);
    }

    @isTest
    static void compareToOtherNullTitle() {
        LookupSearchResult r1 = getSearchResult('a');
        LookupSearchResult r2 = getSearchResult(null);

        Integer compareResult = r1.compareTo(r2);

        System.assertEquals(-1, compareResult);
    }

    @isTest
    static void compareToTitles() {
        LookupSearchResult r1 = getSearchResult('a');
        LookupSearchResult r2 = getSearchResult('b');

        Integer compareResult = r1.compareTo(r2);

        System.assertEquals(-1, compareResult);
    }

    @isTest
    static void gettersTest() {
        // For the sake of code coverage
        LookupSearchResult r = new LookupSearchResult('0010R00000yvEyRQAU', 'type', 'icon', 'title', 'subtitle');

        System.assertEquals('0010R00000yvEyRQAU', r.getId());
        System.assertEquals('type', r.getSObjectType());
        System.assertEquals('icon', r.getIcon());
        System.assertEquals('title', r.getTitle());
        System.assertEquals('subtitle', r.getSubtitle());
    }

    private static LookupSearchResult getSearchResult(String title) {
        return new LookupSearchResult(null, null, null, title, null);
    }

}