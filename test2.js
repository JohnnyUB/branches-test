class Test2 {
    
    constructor() {
        console.log("Test2 constructor");
    }
    
    method1() {
        console.log("Test2 method1");
        return "Test2 method1";
    }
}

const test2 = new Test2();

console.log(test2);

module.exports = test2;
