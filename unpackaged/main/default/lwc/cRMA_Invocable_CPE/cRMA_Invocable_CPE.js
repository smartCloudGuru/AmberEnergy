import { LightningElement, wire, track, api } from "lwc";
import { getRecipes, getDataflows, getDataConnectors } from "lightning/analyticsWaveApi";
import apexGetRecipes from "@salesforce/apex/CRMA_WS.getRecipesAura";
import apexGetDataflows from "@salesforce/apex/CRMA_WS.getDataFlowsAura";

export default class CRMA_Invocable_CPE extends LightningElement {
    allRecipes = [];
    allDataFlows = [];
    showFallBack = false;
    selectedName;
    @track selectedOption = 'recipe';
    selectedRecipe = true;
    selectedDataflow = false;
    selectedDataConnector = false;

    @api inputVariables;

    @track recipeOptions = [];
    @track dataflowOptions = [];
    @track dataConnectorOptions = [];

    @track showPicklistOptions = {
        overallOptions: false,
        fallbackDataFlow: false,
        fallbackRecipe: false,
        picklist: false,
        dataflowPicklist: false,
        dataConnectorPicklist: false
    };

    overallOptions = [
        {label: 'Recipe', value: 'recipe'}, 
        {label: 'Dataflow', value: 'dataflow'},
        {label: 'Data Connector', value: 'dataConnector'}
    ];

    selectedValues = {
        recipe: null,
        dataflow: null,
        dataConnector: null,
        type: null
    };

    findRecipeNameById(id,aList) {
      for (let i = 0; i < aList.length; i++) {
        if (aList[i].targetDataflowId === id) {
          return aList[i].name;
        }
        if(aList[i].id === id) {
          return aList[i].name;
        }
      }
    }


    handleChangeOverallOptions(event) {
        this.setSelectedOption(event.detail.value);
        this.selectedValues.type = this.selectedOption;
        this.dispatchValueChangedEvent('dataFlowType', this.selectedOption);
       
    } 

    setShowPicklistTrue() {
      this.showPicklistOptions.picklist = true;
      if (this.showPicklistOptions.dataflowPicklist) {
        this.showPicklistOptions.overallOptions = true;
        this.showPicklistOptions.fallback = false;

      }
    } 

    setShowDataFlowPicklistTrue() {
      this.showPicklistOptions.dataflowPicklist = true;
      if (this.showPicklistOptions.picklist) {
        this.showPicklistOptions.fallback = false;
        this.showPicklistOptions.overallOptions = true;
      }
    }

    setSelectedOption(option) {
      this.selectedOption = option;
      if (this.selectedOption === 'recipe') {
          this.selectedRecipe = true;
          this.selectedDataflow = false;
          this.selectedDataConnector = false;
      } else if (this.selectedOption === 'dataflow') {
          this.selectedRecipe = false;
          this.selectedDataflow = true;
          this.selectedDataConnector = false;
      } else if (this.selectedOption === 'dataConnector') {
          this.selectedRecipe = false;
          this.selectedDataflow = false;
          this.selectedDataConnector = true;
      }
  }

    @wire(getRecipes, {})
    handleGetRecipes({ data, error }) {
        if (error) {
            console.error("getRecipes ERROR:", JSON.stringify(error));
            apexGetRecipes()
                .then((result) => {

                  result = JSON.parse(result);
                    this.recipeOptions = result.recipes.map(recipe => ({label: recipe.name, value: recipe.targetDataflowId}));
                    if (this.dataFlowId != null && this.selectedOption == 'recipe') {
                      this.selectedValues.recipe = this.dataFlowId;
                      this.setSelectedOption(this.dataFlowType);
                    }
                    this.setShowPicklistTrue();
                    this.allRecipes = result.recipes;
                }
                )
                .catch((error) => {
                    console.error("getRecipes APEX ERROR:", error);
                    console.error(JSON.stringify(error));
                    this.showPicklistOptions.fallbackRecipe = true;
                });
        } else if (data && data.recipes && data.recipes.length > 0) {
            this.recipeOptions = data.recipes.map(recipe => ({label: recipe.name, value: recipe.targetDataflowId}));
            if (this.dataFlowId != null && this.selectedOption == 'recipe') {
              this.selectedValues.recipe = this.dataFlowId;
              this.setSelectedOption(this.dataFlowType);
            }
         
            this.setShowPicklistTrue()
            this.allRecipes = data.recipes;
        } else {
            this.showPicklistOptions.fallback = true;
        }
    }

    logWithStringify(obj) {
      console.log(JSON.stringify(obj));
    }

    @wire(getDataflows, {})
    handleGetDataflows({ data, error }) {
        if (error) {
            console.error("getDataflows ERROR:", error);
            apexGetDataflows()
                .then((result) => {
                    result = JSON.parse(result);
                    this.dataflowOptions = result.dataflows.map(dataflow => ({label: dataflow.name, value: dataflow.id}));
                    console.log('got data flows now');
                    console.log(this.dataFlowId);
                    console.log(this.dataFlowType);
                    console.log(this.dataFlowName);
                    if (this.dataFlowId != null && this.dataFlowType == 'dataflow') {
                      this.selectedValues.dataflow = this.dataFlowId;
                      console.log('set value to');
                      console.log(JSON.stringify(this.selectedValues.dataflow));
                      console.log('existing type');
                      console.log(this.dataFlowType);
                      this.setSelectedOption(this.dataFlowType);
                    }
                    this.setShowDataFlowPicklistTrue();
                    this.allDataFlows = result.dataflows;
                }
                )
                .catch((error) => {
                    console.error("getDataflows APEX ERROR:", error);
                    this.showPicklistOptions.fallbackDataFlow = true;
                });
        } else if (data && data.dataflows) {
            this.dataflowOptions = data.dataflows.map(dataflow => ({label: dataflow.name, value: dataflow.id}));
            if (this.dataFlowId != null && this.dataFlowType == 'dataflow') {
              this.selectedValues.dataflow = this.dataFlowId;
              console.log('set value to');
              console.log(JSON.stringify(this.selectedValues.dataflow));
              console.log('existing type');
                      this.setSelectedOption(this.dataFlowType);
                      console.log(this.dataFlowType);
            }
            this.setShowDataFlowPicklistTrue();
            this.allDataFlows = data.dataflows;
        }
    }

    @wire(getDataConnectors, {})
    handleGetDataConnectors({ data, error }) {
        if (error) {
            console.error("getDataConnectors ERROR:", error);
        } else if (data && data.dataConnectors) {
            this.logWithStringify(data.dataConnectors);

            this.dataConnectorOptions = data.dataConnectors.map(dataConnector => ({label: dataConnector.name, value: dataConnector.id}));
            this.showPicklistOptions.dataConnectorPicklist = true;
        }
    }

    // ... rest of the code

handleOptionChange(event) {
  const name = event.target.name;
  switch(name) {
      case 'dataFlowType':
          let val = event.detail.value;
          if (val == 'Recipe') {
            this.selectedRecipe = true;
            this.selectedDataflow = false;
          }
          this.handleDataflowTypeChange(event);
          break;
      case 'Recipe':
          this.handleRecipeChange(event);
          break;
      case 'Dataflow':
          this.handleDataflowChange(event);
          break;
      case 'Data Connector':
          this.handleDataConnectorChange(event);
          break;
      case 'DataflowId':
          this.handleDataflowIdChange(event);
          break;
      case 'Data flow Name':
          this.handleDataflowNameChange(event);
          break;
      default:
          console.error('Unknown option:', name);
  }
}

handleDataflowTypeChange(event) {
  this.setSelectedOption(event.detail.value);
  
  this.dispatchValueChangedEvent('dataFlowType', this.selectedOption);
}

handleRecipeChange(event) {
  
  this.selectedValues.recipe = event.detail.value;
  this.targetDataflowId = this.selectedValues.recipe.targetDataflowId;
  this.dispatchValueChangedEvent('dataFlowId', this.selectedValues.recipe);
  this.dispatchValueChangedEvent('dataFlowName', this.findRecipeNameById(this.selectedValues.recipe, this.allRecipes));
  
}

handleDataflowChange(event) {
  this.logWithStringify(event.detail);
  this.selectedValues.dataflow = event.detail.value;
  this.dispatchValueChangedEvent('dataFlowId', this.selectedValues.dataflow);
  this.dispatchValueChangedEvent('dataFlowName', this.findRecipeNameById(this.selectedValues.dataflow, this.allDataFlows));
}

handleDataConnectorChange(event) {
  this.logWithStringify(event.detail);
  this.selectedValues.dataConnector = event.detail.value;
  this.dispatchValueChangedEvent('dataFlowId', this.selectedValues.dataConnector);
  this.dispatchValueChangedEvent('dataFlowType', 'DataConnector');
  // Find and dispatch the connector name
  const connector = this.dataConnectorOptions.find(opt => opt.value === this.selectedValues.dataConnector);
  if (connector) {
      this.dispatchValueChangedEvent('dataFlowName', connector.label);
  }
}

handleDataflowIdChange(event) {
  this.logWithStringify(event.detail);
  this.dataFlowId = event.detail.value;
  this.dispatchValueChangedEvent('dataflowId', this.dataFlowId);
  let flowName = this.findRecipeNameById(this.dataFlowId, this.allDataFlows);
  this.dispatchValueChangedEvent('dataflowName', flowName);
}

handleDataflowNameChange(event) {
  this.dataFlowName = event.detail.value;
  this.dispatchValueChangedEvent('dataflowName', this.dataFlowName);
}

// ... rest of the code

    dispatchValueChangedEvent(name, newValue) {
        const valueChangedEvent = new CustomEvent("configuration_editor_input_value_changed", {
            bubbles: true,
            cancelable: false,
            composed: true,
            detail: {
                name,
                newValue,
                newValueDataType: "String",
            },
        });
        this.dispatchEvent(valueChangedEvent);
    }

    getInputVariableValue(variableName) {
        const param = this.inputVariables.find((variable) => variable.name === variableName);
        return param && param.value;
    }

    get dataFlowId() {
        return this.getInputVariableValue("dataFlowId");
    }

    get dataFlowType() {
        return this.getInputVariableValue("dataFlowType");
    }

    get dataFlowName() {
        return this.getInputVariableValue("dataFlowName");
    }
}