import { twMerge } from "tailwind-merge";

interface ButtonProps extends React.ButtonHTMLAttributes<HTMLButtonElement> {
  children: React.ReactNode;
  className?: string;
}

const ActionButton = ({ children, className, ...props }: ButtonProps) => {
  const baseStyle = `
    bg-green-600 hover:bg-green-700 text-white px-3 py-2 rounded text-base
    font-medium transition shadow-sm flex items-center gap-1
    disabled:bg-gray-300 disabled:text-gray-500 disabled:cursor-not-allowed
    `;

  return (
    <button {...props} className={twMerge(baseStyle, className)}>
      {children}
    </button>
  );
};

export default ActionButton;
