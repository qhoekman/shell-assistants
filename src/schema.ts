export type Root = {
  ticket: Ticket;
  models: Models;
  ignorePatterns: string[];
  prompts: Prompts;
  output: Output;
};

type Ticket = {
  id: number;
  title: string;
  description: string;
};

type Models = {
  commit: string;
  staged: string;
  code: string;
};

type Prompts = {
  project: string;
  codeStandards: string;
  namingConventions: string;
  commitMessage: string;
  staged: string;
  review: string;
  bestPractices: BestPractices;
};

type BestPractices = Record<string, string>;

type Output = {
  staged: string;
  commit: string;
  prompt: string;
  review: string;
};
