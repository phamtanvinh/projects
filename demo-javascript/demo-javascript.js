

function square(number){
    return number*number
}

function myFunc(theObject){
    theObject.make = 'Toyota';
}

console.log(square(9))

var x = 0;

if (x) {
    console.log('OK')
}
else{
    console.log('KO')
}

fn = (x1=1, ...args) => {
    console.log(x1)
    return args
}

y = ['1', '2', '3', '4']

console.log(y.map( x => x.length))