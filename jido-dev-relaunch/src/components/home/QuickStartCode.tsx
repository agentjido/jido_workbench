import { motion } from "framer-motion";

const code = `defmodule ResearchAgent do
  use JidoAI.Agent

  def init(args) do
    {:ok, %{
      model: {:openai, "gpt-4"}, # or anthropic, etc
      budget: 10_000, # max tokens
      topic: args[:topic]
    }}
  end

  def handle_action(:research, state) do
    # Agent makes LLM call with budget tracking
    case JidoAI.chat(state, prompt) do
      {:ok, response, new_state} ->
        {:ok, %{new_state | findings: response}}
      {:error, :budget_exceeded} ->
        {:error, :out_of_tokens}
    end
  end
end

# Start 1,000 supervised research agents
for topic <- topics do
  JidoAI.start_agent(ResearchAgent, topic: topic)
end`;

export function QuickStartCode() {
  return (
    <motion.section
      initial={{ opacity: 0, y: 20 }}
      whileInView={{ opacity: 1, y: 0 }}
      transition={{ duration: 0.5 }}
      viewport={{ once: true }}
      className="mb-16"
    >
      <div className="flex justify-between items-center mb-5">
        <span className="font-bold text-sm tracking-wider">QUICK START</span>
        <span className="text-muted-foreground text-[11px]">run in less than 2 minutes</span>
      </div>

      <div className="code-block overflow-hidden">
        <div className="code-header">
          <span className="text-muted-foreground text-xs">lib/my_app/research_agent.ex</span>
          <div className="flex gap-3">
            <span className="text-primary text-[10px] cursor-pointer hover:underline">LIVEBOOK</span>
            <span className="text-muted-foreground text-[10px] cursor-pointer hover:text-foreground">GITHUB</span>
          </div>
        </div>
        <div className="p-6 overflow-x-auto">
          <pre className="text-xs leading-relaxed">
            {code.split('\n').map((line, i) => {
              // Simple syntax highlighting
              let highlighted = line;
              
              // Comments
              if (line.trim().startsWith('#')) {
                return <div key={i} className="syntax-comment">{line}</div>;
              }
              
              // Inline comments
              const commentIndex = line.indexOf(' #');
              let mainPart = line;
              let commentPart = '';
              if (commentIndex > -1) {
                mainPart = line.substring(0, commentIndex);
                commentPart = line.substring(commentIndex);
              }
              
              return (
                <div key={i}>
                  {mainPart
                    .split(/(\b(?:defmodule|def|do|end|use|case|for)\b|"[^"]*"|:[a-z_]+|[A-Z][A-Za-z.]+|\d+[_\d]*)/g)
                    .map((part, j) => {
                      if (/^(defmodule|def|do|end|use|case|for)$/.test(part)) {
                        return <span key={j} className="syntax-keyword">{part}</span>;
                      }
                      if (/^".*"$/.test(part)) {
                        return <span key={j} className="syntax-string">{part}</span>;
                      }
                      if (/^:[a-z_]+$/.test(part)) {
                        return <span key={j} className="syntax-atom">{part}</span>;
                      }
                      if (/^[A-Z][A-Za-z.]+$/.test(part)) {
                        return <span key={j} className="syntax-type">{part}</span>;
                      }
                      if (/^\d+[_\d]*$/.test(part)) {
                        return <span key={j} className="syntax-string">{part}</span>;
                      }
                      return part;
                    })}
                  {commentPart && <span className="syntax-comment">{commentPart}</span>}
                </div>
              );
            })}
          </pre>
        </div>
      </div>
    </motion.section>
  );
}
