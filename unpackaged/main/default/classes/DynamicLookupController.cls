/**
 * Created by ukaya01 on 9/21/2021.
 */

public class DynamicLookupController {

    public class SearchParameter{
        public string objectName {get; set;}
        public string filters {get; set;}
        public string icon {get; set;}
    }

    private final static Integer MAX_RESULTS = 5;

    @AuraEnabled(Cacheable=true)
    public static List<LookupSearchResult> search(String searchTerm, String rawSearchTerm, List<String> selectedIds, string searchParams) {

        // Prepare query parameters
        searchTerm += '*';

        // Execute search query
        List<SearchParameter> searchParameters = (List<SearchParameter>)JSON.deserialize(searchParams, List<SearchParameter>.class);
        string returnObjects = '';
        for(SearchParameter param : searchParameters){
            string searchString = param.objectName + '(Id, Name';
            if(!string.isEmpty(param.filters)){
                searchString += ' WHERE ' + param.filters;
            }
            searchString += ')';
            if(!string.isEmpty(returnObjects)){
                returnObjects += ',';
            }
            returnObjects += searchString;
        }

        String searchQuery='FIND \'' + searchTerm + '\' IN ALL FIELDS RETURNING ' + returnObjects + ' LIMIT ' + MAX_RESULTS;

        List<List<SObject>> searchResults = search.query(searchQuery);

        // Prepare results
        List<LookupSearchResult> results = new List<LookupSearchResult>();

        for (Integer i = 0; i < searchResults.size(); i++) {
            SearchParameter param = searchParameters[i];
            sObject[] records = (List<sObject>) searchResults[i];
            for (sObject sObj : records) {
                results.add(new LookupSearchResult((string)sObj.get('Id'), param.objectName, param.icon, (string)sObj.get('Name'), ''));
            }
        }

        // Optionally sort all results on title
        results.sort();

        return results;
    }

}