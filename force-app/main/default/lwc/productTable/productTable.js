import { LightningElement, wire, track } from 'lwc';
import getProducts from '@salesforce/apex/ProductTableController.getProducts';
import createProduct from '@salesforce/apex/ProductTableController.createProduct';
import updateProduct from '@salesforce/apex/ProductTableController.updateProduct';
import deleteProduct from '@salesforce/apex/ProductTableController.deleteProduct';
import { refreshApex } from '@salesforce/apex';

export default class ProductTable extends LightningElement {

    @track products = [];
    @track searchKey = '';

    @track currentPage = 1;
    @track pageSize = 5;
    @track totalPages = 0;

    @track isLoading = true;

    showForm = false;
    productRecord = {};
    formTitle = 'New Product';

    wiredProductsResult;
    searchTimeout;

    sortBy = 'Name';             
    sortDirection = 'ASC';   

    pageSizeOptions = [{ label: '5', value: 5 },{ label: '10', value: 10 },{ label: '20', value: 20 }];
    productTypeOptions = [ { label: '0', value: '0' }, { label: 'TestType', value: 'TestType' }];


    @wire(getProducts, {searchKey: '$searchKey',sortBy: '$sortBy',sortDirection: '$sortDirection'})
    wiredProducts(result) {
        this.wiredProductsResult = result;

        if (result.data) {
            this.products = result.data;
            this.currentPage = 1;
            this.totalPages = Math.ceil(this.products.length / this.pageSize);
            this.isLoading = false;
        } 
        else if (result.error) {
            console.error(result.error);
            this.isLoading = false;
        }
    }

    handleSearchKeyChange(event) {
        const value = event.target.value;
        clearTimeout(this.searchTimeout);

        this.searchTimeout = setTimeout(() => {this.isLoading = true;this.searchKey = value;}, 300);
    }

    handleSort(event) {
        const field = event.currentTarget.dataset.field;
        this.isLoading = true;

        if (this.sortBy === field) {
            this.sortDirection = this.sortDirection === 'ASC' ? 'DESC' : 'ASC';
        } else {
            this.sortBy = field;
            this.sortDirection = 'ASC';
        }
    }
    openForm() {
        this.formTitle = 'New Product';
        this.productRecord = { Name: '', Price__c: null,Amount__c: null, Available__c: false};
        this.showForm = true;
    }
    handleInputChange(event) {
        const field = event.target.name;

        let value;
        if (event.target.type === 'checkbox') {
            value = event.target.checked;
        } else {
            value = event.target.value;
        }

        this.productRecord = {...this.productRecord, [field]: value
        };
    }


    handleSave() {
         if (!this.productRecord.Name || !this.productRecord.Price__c) {
            alert('Name and Price are required');
            return;
        }

        this.isLoading = true;

        const action = this.productRecord.Id ? updateProduct : createProduct;

        action({ product: this.productRecord })
            .then(() => {this.showForm = false;
                return refreshApex(this.wiredProductsResult);
            })
            .catch(error => console.error(error))
            .finally(() => this.isLoading = false);
    }

    handleDelete(event) {
        this.isLoading = true;
        const productId = event.target.dataset.id;

        deleteProduct({ productId })
            .then(() => refreshApex(this.wiredProductsResult))
            .catch(error => console.error(error))
            .finally(() => this.isLoading = false);
    }

    handleNext() {
        if (this.currentPage < this.totalPages) {
            this.currentPage++;
        }
    }

    handlePrev() {
        if (this.currentPage > 1) {
            this.currentPage--;
        }
    }

    handlePageSizeChange(event) {
        this.pageSize = Number(event.detail.value);
        this.totalPages = Math.ceil(this.products.length / this.pageSize);
        this.currentPage = 1;
    }


    get paginatedProducts() {
        const start = (this.currentPage - 1) * this.pageSize;
        return this.products.slice(start, start + this.pageSize);
    }

    get isFirstPage() {
        return this.currentPage === 1;
    }

    get isLastPage() {
        return this.currentPage === this.totalPages;
    }



}