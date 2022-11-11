// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.2 <0.9.0;

contract RizalLibrary {

    // Instantiation of variables here
        // i.e. current_owner, balance_owner, members_contract

    address private student;

    address private librarian;

    enum BorrowStatus { Clear, Borrowed, HoldOrder }

    BorrowStatus borrow_status;

    BorrowStatus constant defaultChoice = BorrowStatus.Clear;

    enum Enrolled { Enrolled, NotEnrolled }

    Enrolled is_enrolled;

    Enrolled constant deafultStatus = Enrolled.Enrolled;

    // enum BookStatus { Available, Borrowed }

    // BookStatus book_status;

    // BookStatus constant defaultStatus = BookStatus.Available;

    struct Student {
        uint id_num;
        BorrowStatus borrow_status;
        uint fine;
        uint borrowed_book;
        uint due_date;
        Enrolled is_enrolled;
    }

    // struct Book {
    //     uint book_call_num;
    //     BookStatus book_status;
    //     uint due_date;
    // }

    mapping(address => Student) public students;
    // mapping(uint => Book) public books;

    // Modifiers here

    //create a modifier that checks if the student has borrowed a book
    modifier check_borrowed() {
        require(
            students[msg.sender].borrow_status == BorrowStatus.Borrowed, 
            "You haven't borrowed a book!"
        );
        _;
    }   

    modifier check_student_borrow() {
        require(
            students[msg.sender].borrow_status == BorrowStatus.Clear, 
            "You can't borrow a book because you already borrowed one or have a pending hold order!"
        );
        _;
    }   

    modifier check_hold() {
        require(
            students[msg.sender].borrow_status == BorrowStatus.HoldOrder, 
            "You don't have a hold order, go borrow a book if you haven't!"
        );
        _;
    }

    modifier check_fine() {
        require(
            msg.value == 50000,
            "Fine payment is not enough!"
        );
        _;
    }

    modifier isLibrarian() {
        require(
            msg.sender == librarian, 
            "You are not the librarian!"
        );
        _;
    }   

    modifier isStudent() {
        require(
            // Assumption: ID number must be an int greater than 0
            students[msg.sender].is_enrolled == Enrolled.Enrolled, 
            "You are not a student here!"
        );
        _;
    }

    constructor() {
        librarian = msg.sender;
    }

    // Class Methods here

    function addStudent (uint _id, address _student_add) public isLibrarian {
        students[_student_add] = Student({
                id_num: _id,
                is_enrolled: Enrolled.Enrolled,
                borrow_status: BorrowStatus.Clear,
                fine: 0,
                borrowed_book: 0,
                due_date: 0
            });
    }

    function viewLibrarian() external view returns(address) {
        return librarian;
    } 

    function borrowBook(uint book_call_num) external check_student_borrow isStudent {
        // Adding 2 weeks worth of relative unix time
        students[msg.sender].due_date = block.timestamp + 1180758;
        students[msg.sender].borrow_status = BorrowStatus.Borrowed;
        students[msg.sender].borrowed_book = book_call_num;
    }

    function returnBook() external check_borrowed isStudent{
        students[msg.sender].borrow_status = BorrowStatus.Clear;
        students[msg.sender].borrowed_book = 0;

        //Checking if within due date of 2 weeks
         if (block.timestamp - students[msg.sender].due_date > 0) {
            students[msg.sender].fine += 50000;
            students[msg.sender].borrow_status = BorrowStatus.HoldOrder;
         }
    }

    function payBalance() external payable check_hold check_fine isStudent {
        students[msg.sender].borrow_status = BorrowStatus.Clear;
        students[msg.sender].fine -= msg.value;
    }

}
