import gleam/list
import gleam/string
import simplifile

const program: String = "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++.>+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++.<.>.<.>.,."

fn fill_stack(size: Int) -> String {
  case size - 1 {
    0 -> "\n\n"
    _ -> "\n\tpush 0" <> fill_stack(size - 1)
  }
}

fn op_to_asm(op: String) -> String {
  case op {
    "+" -> "\tmov al, [rsp]\n\tadd al, 1\n\tmov [rsp], al\n"
    "-" -> "\tmov al, [rsp]\n\tsub al, 1\n\tmov [rsp], al\n"
    ">" -> "\tadd rsp, 1\n"
    "<" -> "\tsub rsp, 1\n"
    "." ->
      "\tmov rax, 1\n\tmov rdi, 1\n\tmov rsi, rsp\n\tmov rdx, 1\n\tsyscall\n"
    "," ->
      "\tmov rax, 0\n\tmov rdi, 0\n\tmov rsi, rsp\n\tmov rdx, 1\n\tsyscall\n"
    "[" | "]" | _ -> ""
    // TODO: Loops
  }
}

pub fn main() {
  let _ =
    simplifile.write(
      contents: "section .text\nglobal _start\n_start:\n" <> fill_stack(100),
      to: "out.asm",
    )

  program
  |> string.to_graphemes
  |> list.map(op_to_asm)
  |> list.append(["\n\tmov rax, 60\n\tmov rdi, 0\n\tsyscall"])
  |> string.concat
  |> simplifile.append(to: "out.asm")
}
