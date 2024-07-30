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
        name: 'Play',
        slug: 'play',
      },
    ],
  },
];
