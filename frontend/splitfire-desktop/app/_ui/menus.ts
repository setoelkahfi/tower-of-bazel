export type Item = {
  name: string;
  slug: string;
  description?: string;
};

export const menus: { items: Item[] }[] = [
  {
    items: [
      {
        name: 'Home',
        slug: '',
      },
      {
        name: 'Ready to Play!',
        slug: 'ready-to-play',
      },
    ],
  },
];
