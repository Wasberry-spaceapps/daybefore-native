import Dexie, { type EntityTable } from 'dexie';

interface JournalEntry {
  id: string;
  content: string;
  createdAt: number;
  updatedAt: number;
}

interface CorePoint {
  id: string;
  name: string;
  content: string;
  createdAt: number;
  updatedAt: number;
}

interface Issue {
  id: string;
  name: string;
  content?: string;
  isArchived: boolean;
  createdAt: number;
  updatedAt: number;
}

interface IssueEntry {
  id: string;
  issueId: string;
  content: string;
  createdAt: number;
  updatedAt: number;
}

const db = new Dexie('DayBeforeDB') as Dexie & {
  journalEntries: EntityTable<JournalEntry, 'id'>;
  corePoints: EntityTable<CorePoint, 'id'>;
  issues: EntityTable<Issue, 'id'>;
  issueEntries: EntityTable<IssueEntry, 'id'>;
};

db.version(2).stores({
  journalEntries: 'id, createdAt, updatedAt',
  corePoints: 'id, createdAt, updatedAt',
  issues: 'id, isArchived, createdAt, updatedAt',
  issueEntries: 'id, issueId, createdAt, updatedAt'
});

export type { JournalEntry, CorePoint, Issue, IssueEntry };
export { db };
