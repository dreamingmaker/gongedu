interface HelpTextProps extends React.AreaHTMLAttributes<HTMLAreaElement> {
  children: React.ReactNode;
  title?: string;
}

const HelpText = ({ children, title, ...props }: HelpTextProps) => {
  const baseH3Style = "font-bold text-lg text-gray-900 dark:text-white mb-2";

  return (
    <section {...props}>
      <h3 className={baseH3Style}>{title}</h3>
      {children}
    </section>
  );
};

export default HelpText;
