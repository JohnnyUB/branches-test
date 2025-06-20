class Test1 {
    
    constructor() {
        console.log("Test1 constructor");
    }
    
    method1() {
        console.log("Test1 method1");
        console.log("This is a change from task1")
        return "Test1 method1";
    }
}



const test1 = new Test1();

console.log(test1);

module.exports = test1;
