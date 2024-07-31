import { SkeletonCard } from "./_ui/skeleton-card";

export async function generateStaticParams() {
  const posts = [
    { slug: "post-1" },
    { slug: "post-2" },
    { slug: "post-3" },
  ];
 
  return posts.map((post) => ({
    slug: post.slug,
  }))
}

export default function Page() {
  return (
    <div className="space-y-9">
      <div className="flex justify-between">
        <div className="self-start">
          <h1 className="text-3xl font-bold">Discover</h1>
        </div>
      </div>
      <div>
        <div className="prose prose-sm prose-invert max-w-none">
          <div className="grid grid-cols-3 gap-6">
            {Array.from({ length: 20 }).map((_, i) => (
              <SkeletonCard key={i} />
            ))}
          </div>
        </div>
      </div>
    </div>
  );
}
