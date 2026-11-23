import Foundation

public struct QuizQuestion: Identifiable {
    public let id: String = UUID().uuidString
    public let questionText: String
    public let options: [String]
    public let correctOptionIndex: Int
    public let explanation: String
    
    public init(questionText: String, options: [String], correctOptionIndex: Int, explanation: String) {
        self.questionText = questionText
        self.options = options
        self.correctOptionIndex = correctOptionIndex
        self.explanation = explanation
    }
}

public struct QuizDatabase {
    public static let questions: [QuizQuestion] = [
        QuizQuestion(
            questionText: "Which code snippet correctly allocates a new Node with value 10 in C++?",
            options: [
                "Node n = Node(10);",
                "Node* n = new Node(10);",
                "Node* n = &Node(10);",
                "Node n = malloc(sizeof(Node));"
            ],
            correctOptionIndex: 1,
            explanation: "In C++, dynamic memory allocation on the Heap is done using the 'new' operator, which returns a pointer to the allocated type (e.g., 'Node*'). 'Node n = Node(10);' allocates the node on the Stack instead."
        ),
        QuizQuestion(
            questionText: "What is the primary risk of executing 'head = head->next;' without saving the original 'head' pointer or freeing it first, assuming it is the only pointer referencing that node?",
            options: [
                "A segmentation fault occurs immediately.",
                "The compile fails due to invalid pointer reassignment.",
                "It causes a Memory Leak because the original head node cannot be accessed or deleted.",
                "The list automatically self-cleans its heap memory."
            ],
            correctOptionIndex: 2,
            explanation: "Because heap-allocated memory must be manually freed in C/C++, overwriting the last pointer to a node without calling 'delete' or 'free' makes that node unreachable. This is called a memory leak."
        ),
        QuizQuestion(
            questionText: "In a Singly Linked List, why must we perform 'newNode->next = currNode->next;' before 'currNode->next = newNode;' when inserting a node in the middle?",
            options: [
                "To ensure the list is traversed backwards.",
                "If we overwrite 'currNode->next' first, we lose the link to the remainder of the list, cutting it off.",
                "C++ compilers throw a strict syntax error if pointer assignments are reversed.",
                "It is purely a stylistic preference and has no functional difference."
            ],
            correctOptionIndex: 1,
            explanation: "If you execute 'currNode->next = newNode;' first, the link to the rest of the list ('currNode->next') is broken and lost. Consequently, setting 'newNode->next = currNode->next' would make the new node point to itself!"
        ),
        QuizQuestion(
            questionText: "What is the Big-O time complexity of inserting a node at the head of a Singly Linked List vs. inserting at the beginning of a dynamic array (like std::vector)?",
            options: [
                "Linked List: O(1) | Array: O(n)",
                "Linked List: O(n) | Array: O(1)",
                "Linked List: O(log n) | Array: O(n)",
                "Linked List: O(1) | Array: O(1)"
            ],
            correctOptionIndex: 0,
            explanation: "Inserting at the head of a linked list only requires adjusting 2 pointers (O(1) time). Inserting at the start of a dynamic array requires shifting all existing elements in memory by one slot, which takes O(n) time."
        ),
        QuizQuestion(
            questionText: "Which algorithm is commonly used to detect a cycle/loop in a dynamic Linked List with O(N) time and O(1) space?",
            options: [
                "Dijkstra's Shortest Path Algorithm",
                "Floyd's Cycle-Finding Algorithm (Tortoise and Hare)",
                "Binary Search on Pointer Addresses",
                "Kruskal's Minimal Spanning Tree"
            ],
            correctOptionIndex: 1,
            explanation: "Floyd's Cycle-Finding Algorithm uses two pointers (a slow 'tortoise' moving 1 step and a fast 'hare' moving 2 steps). If there is a loop, the fast pointer will eventually catch up and meet the slow pointer, detecting the cycle using O(1) extra space."
        )
    ]
}
