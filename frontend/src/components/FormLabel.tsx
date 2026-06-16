import { twMerge } from "tailwind-merge";

interface FormLabelProps extends React.LabelHTMLAttributes<HTMLLabelElement> {
  children: React.ReactNode;
  className?: string;
}

const FormLabel = ({ children, className, ...props }: FormLabelProps) => {
  const baseStyle =
    "block text-base font-medium text-gray-700 dark:text-gray-300 mb-1";

  return (
    <label {...props} className={twMerge(baseStyle, className)}>
      {children}
    </label>
  );
};

export default FormLabel;
