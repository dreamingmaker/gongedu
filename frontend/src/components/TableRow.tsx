import { twMerge } from "tailwind-merge";

interface TableRowProps extends React.TdHTMLAttributes<HTMLTableCellElement> {
  children: React.ReactNode;
  className?: string;
}

const TableRow = ({ children, className, ...props }: TableRowProps) => {
  const baseStyle =
    "px-6 py-4 text-base text-center text-gray-500 dark:text-gray-400";

  return (
    <td {...props} className={twMerge(baseStyle, className)}>
      {children}
    </td>
  );
};

export default TableRow;
