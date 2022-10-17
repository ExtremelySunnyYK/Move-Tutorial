// print hello world

module {
    use std::debug;

script {
    // Import the Debug module published at the named account address Std.

    const ONE: u64 = 1;

    fun main(x: u64) {
        let sum = x + ONE;
        Debug::print(&sum)
    }
}
}