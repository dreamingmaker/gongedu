import { twMerge } from "tailwind-merge";

interface ButtonProps extends React.ButtonHTMLAttributes<HTMLButtonElement> {
  children: React.ReactNode;
  type?: "button" | "submit" | "reset" | undefined;
  className?: string;
}

const FormButton = ({
  children,
  type = "button",
  className,
  ...props
}: ButtonProps) => {
  const baseStyle = `
    text-base bg-gray-100 dark:bg-gray-700 hover:bg-gray-200 dark:hover:bg-indigo-500
    text-gray-700 dark:text-gray-200 px-3 py-2 rounded cursor-pointer transition
    `;

  return (
    <button type={type} {...props} className={twMerge(baseStyle, className)}>
      {children}
    </button>
  );
};

export default FormButton;
